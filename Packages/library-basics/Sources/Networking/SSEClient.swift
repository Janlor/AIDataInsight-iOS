//
//  SSEClient.swift
//  LibraryBasics
//
//  Created by Janlor on 4/30/26.
//

import Foundation

enum SSEClientError: LocalizedError {
    case invalidResponse
    case badStatusCode(Int)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid SSE response."
        case .badStatusCode(let statusCode):
            return "SSE request failed with status code: \(statusCode)."
        }
    }
}

struct SSEEventParser {
    private var dataLines: [String] = []

    mutating func consume(line: String) -> String? {
        let normalizedLine = line.trimmingCharacters(in: .newlines)

        if normalizedLine.isEmpty {
            return flush()
        }

        guard normalizedLine.hasPrefix("data:") else {
            return nil
        }

        let value = String(normalizedLine.dropFirst(5)).trimmingCharacters(in: .whitespaces)
        dataLines.append(value)
        return nil
    }

    mutating func finish() -> String? {
        flush()
    }

    private mutating func flush() -> String? {
        guard dataLines.isEmpty == false else { return nil }
        defer { dataLines.removeAll(keepingCapacity: true) }
        return dataLines.joined(separator: "\n")
    }
}

public final class SSEClient {
    public var onEvent: ((String) -> Void)?
    public var onComplete: ((Error?) -> Void)?

    private let request: URLRequest
    private let session: URLSession
    private var streamTask: _Concurrency.Task<Void, Never>?
    private var hasCompleted = false

    public convenience init(request: URLRequest) {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        configuration.timeoutIntervalForResource = 300
        self.init(request: request, session: URLSession(configuration: configuration))
    }

    init(request: URLRequest, session: URLSession) {
        self.request = request
        self.session = session
    }

    public func start() {
        guard streamTask == nil else { return }

        streamTask = _Concurrency.Task { [weak self] in
            guard let self else { return }

            do {
                let (bytes, response) = try await session.bytes(for: request)

                guard let httpResponse = response as? HTTPURLResponse else {
                    finish(SSEClientError.invalidResponse)
                    return
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                    finish(SSEClientError.badStatusCode(httpResponse.statusCode))
                    return
                }

                var parser = SSEEventParser()

                for try await line in bytes.lines {
                    if _Concurrency.Task.isCancelled {
                        finish(nil)
                        return
                    }

                    if let payload = parser.consume(line: line), payload.isEmpty == false {
                        onEvent?(payload)
                    }
                }

                if let payload = parser.finish(), payload.isEmpty == false {
                    onEvent?(payload)
                }

                finish(nil)
            } catch is CancellationError {
                finish(nil)
            } catch let error as URLError where error.code == .cancelled {
                finish(nil)
            } catch {
                finish(error)
            }
        }
    }

    public func cancel() {
        streamTask?.cancel()
        session.invalidateAndCancel()
        finish(nil)
    }

    private func finish(_ error: Error?) {
        guard hasCompleted == false else { return }
        hasCompleted = true
        streamTask = nil
        session.finishTasksAndInvalidate()
        onComplete?(error)
    }
}
