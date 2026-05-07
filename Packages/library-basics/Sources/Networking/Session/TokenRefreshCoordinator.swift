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
    let state = RefreshContinuationState()

    return try await withTaskCancellationHandler {
        try await withCheckedThrowingContinuation { continuation in
            state.setContinuation(continuation)

            let cancellable = service.refreshToken(token) { succeed, errorMessage in
                if let errorMessage, succeed == false {
                    state.resume(throwing: ResponseError.server(402, errorMessage))
                } else {
                    state.resume(returning: succeed)
                }
            }

            state.setCancellable(cancellable)
        }
    } onCancel: {
        state.cancel()
    }
}

private final class RefreshContinuationState: @unchecked Sendable {
    private let lock = NSLock()
    private var continuation: CheckedContinuation<Bool, Error>?
    private var cancellable: Cancellable?
    private var hasResumed = false

    func setContinuation(_ continuation: CheckedContinuation<Bool, Error>) {
        lock.lock()
        defer { lock.unlock() }
        self.continuation = continuation
    }

    func setCancellable(_ cancellable: Cancellable?) {
        lock.lock()
        defer { lock.unlock() }
        self.cancellable = cancellable
    }

    func resume(returning value: Bool) {
        let continuation = takeContinuation()
        continuation?.resume(returning: value)
    }

    func resume(throwing error: Error) {
        let continuation = takeContinuation()
        continuation?.resume(throwing: error)
    }

    func cancel() {
        lock.lock()
        let cancellable = self.cancellable
        lock.unlock()

        cancellable?.cancel()
        resume(throwing: CancellationError())
    }

    private func takeContinuation() -> CheckedContinuation<Bool, Error>? {
        lock.lock()
        defer { lock.unlock() }
        guard hasResumed == false else { return nil }
        hasResumed = true
        let continuation = continuation
        self.continuation = nil
        return continuation
    }
}
