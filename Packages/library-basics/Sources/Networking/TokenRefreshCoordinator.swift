//
//  TokenRefreshCoordinator.swift
//  LibraryBasics
//
//  Created by OpenAI on 2025/2/14.
//

import Foundation

public enum TokenRefreshCoordinatorError: LocalizedError {
    case timeout

    public var errorDescription: String? {
        switch self {
        case .timeout:
            return "Token refresh timed out."
        }
    }
}

public actor TokenRefreshCoordinator {
    private let tokenRefreshService: TokenRefreshService
    private let timeoutNanoseconds: UInt64
    private var inFlightTask: _Concurrency.Task<Bool, Error>?

    public init(
        tokenRefreshService: TokenRefreshService,
        timeoutNanoseconds: UInt64 = 10_000_000_000
    ) {
        self.tokenRefreshService = tokenRefreshService
        self.timeoutNanoseconds = timeoutNanoseconds
    }

    public func refreshToken(_ token: String?) async throws -> Bool {
        guard let token else { return false }

        if let inFlightTask {
            return try await inFlightTask.value
        }

        let task = _Concurrency.Task { [tokenRefreshService, timeoutNanoseconds] in
            try await withThrowingTaskGroup(of: Bool.self) { group in
                group.addTask {
                    try await performRefresh(token, service: tokenRefreshService)
                }

                group.addTask {
                    try await _Concurrency.Task.sleep(nanoseconds: timeoutNanoseconds)
                    throw TokenRefreshCoordinatorError.timeout
                }

                let result = try await group.next() ?? false
                group.cancelAll()
                return result
            }
        }

        inFlightTask = task
        defer { inFlightTask = nil }
        return try await task.value
    }
}

private func performRefresh(
    _ token: String,
    service: TokenRefreshService
) async throws -> Bool {
    try await withCheckedThrowingContinuation { continuation in
        _ = service.refreshToken(token) { succeed, errorMessage in
            if let errorMessage, succeed == false {
                continuation.resume(throwing: ResponseError.server(402, errorMessage))
            } else {
                continuation.resume(returning: succeed)
            }
        }
    }
}
