//
//  CommonRequester.swift
//  LibraryCommon
//
//  Created by Janlor on 2025/12/29.
//

import Foundation
import Networking

public enum DataState<T> {
    case cache(T)
    case fresh(T)
    case empty
    case error(Error)
}

public struct AnyCodable: Codable { }

public enum CommonRequesterError: LocalizedError {
    case emptyResponse
    case requestFailed
    
    public var errorDescription: String? {
        switch self {
        case .emptyResponse:
            return "请求成功，但返回数据为空。"
        case .requestFailed:
            return "请求失败。"
        }
    }
}

public protocol Requesting {

    @discardableResult
    static func request<T: Codable>(
        _ target: CustomTargetType,
        loadCache: Bool,
        completion: @escaping (DataState<T>) -> Void
    ) -> CancellableTask
    
    @discardableResult
    static func requestNet<T: Codable>(
        _ target: CustomTargetType,
        completion: @escaping (T?, Error?) -> Void
    ) -> CancellableTask
    
    @discardableResult
    static func requestVoid(
        _ target: CustomTargetType,
        completion: @escaping (Bool, Error?) -> Void
    ) -> CancellableTask
    
    @discardableResult
    static func requestSSE(
        _ request: URLRequest,
        onEvent: @escaping (String) -> Void,
        completion: @escaping (Error?) -> Void
    ) -> CancellableTask
    
    static func requestNet<T: Codable>(
        _ target: CustomTargetType
    ) async throws -> T
    
    static func requestVoid(
        _ target: CustomTargetType
    ) async throws
    
    static func requestSSE(
        _ request: URLRequest
    ) -> AsyncThrowingStream<String, Error>
}

private final class CancellableTaskBox: @unchecked Sendable {
    var task: CancellableTask?
}

public final class NetworkCancellableTask: CancellableTask {

    private var cancellable: Cancellable?
    public var onFinish: (() -> Void)?

    public init() {}

    public func bind(_ cancellable: Cancellable) {
        self.cancellable = cancellable
    }

    public func cancel() {
        cancellable?.cancel()
        finish()
    }

    public func finish() {
        guard onFinish != nil else { return }
        onFinish?()
        onFinish = nil
    }

    public var isCancelled: Bool {
        cancellable?.isCancelled ?? true
    }
}

public final class ClosureCancellableTask: CancellableTask {

    private let cancelHandler: () -> Void
    public var onFinish: (() -> Void)?
    private(set) public var isCancelled = false

    public init(cancelHandler: @escaping () -> Void) {
        self.cancelHandler = cancelHandler
    }

    public func cancel() {
        guard !isCancelled else { return }
        isCancelled = true
        cancelHandler()
        finish()
    }

    public func finish() {
        guard onFinish != nil else { return }
        onFinish?()
        onFinish = nil
    }
}

public enum CommonRequester: Requesting {

    @discardableResult
    public static func request<T: Codable>(
        _ target: CustomTargetType,
        loadCache: Bool = true,
        completion: @escaping (DataState<T>) -> Void
    ) -> CancellableTask {
        let wrapper = NetworkCancellableTask()
        let cancellable = ResponseModel<T>.requestableWithState(
            target,
            loadCache: loadCache
        ) { state in
            defer { wrapper.finish() }
            deliver {
                switch state {
                case .cache(let model):
                    if let data = model.data {
                        completion(.cache(data))
                    } else {
                        completion(.empty)
                    }
                    
                case .fresh(let model):
                    if let data = model.data {
                        completion(.fresh(data))
                    } else {
                        completion(.empty)
                    }
                    
                case .empty:
                    completion(.empty)
                    
                case .error(let error):
                    completion(.error(error))
                }
            }
        }
        
        wrapper.bind(cancellable)
        return wrapper
    }
    
    @discardableResult
    public static func requestNet<T: Codable>(
        _ target: CustomTargetType,
        completion: @escaping (T?, Error?) -> Void
    ) -> CancellableTask {
        var task: _Concurrency.Task<Void, Never>?
        let wrapper = ClosureCancellableTask {
            task?.cancel()
        }
        task = _Concurrency.Task {
            defer { deliver { wrapper.finish() } }
            do {
                let response = try await NetworkExecutor().request(target, as: ResponseModel<T>.self)
                deliver {
                    completion(response.data, response.data == nil ? CommonRequesterError.emptyResponse : nil)
                }
            } catch {
                deliver {
                    completion(nil, error)
                }
            }
        }
        return wrapper
    }
    
    public static func requestNet<T: Codable>(
        _ target: CustomTargetType
    ) async throws -> T {
        let taskBox = CancellableTaskBox()
        
        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                taskBox.task = requestNet(target) { (model: T?, error) in
                    if let error {
                        continuation.resume(throwing: error)
                    } else if let model {
                        continuation.resume(returning: model)
                    } else {
                        continuation.resume(throwing: CommonRequesterError.emptyResponse)
                    }
                }
            }
        } onCancel: {
            taskBox.task?.cancel()
        }
    }
    
    @discardableResult
    public static func requestVoid(
        _ target: CustomTargetType,
        completion: @escaping (Bool, Error?) -> Void
    ) -> CancellableTask {
        var task: _Concurrency.Task<Void, Never>?
        let wrapper = ClosureCancellableTask {
            task?.cancel()
        }
        task = _Concurrency.Task {
            defer { deliver { wrapper.finish() } }
            do {
                _ = try await NetworkExecutor().request(target, as: ResponseModel<AnyCodable>.self)
                deliver {
                    completion(true, nil)
                }
            } catch {
                deliver {
                    completion(false, error)
                }
            }
        }
        return wrapper
    }
    
    public static func requestVoid(
        _ target: CustomTargetType
    ) async throws {
        let taskBox = CancellableTaskBox()
        
        try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                taskBox.task = requestVoid(target) { success, error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else if success {
                        continuation.resume()
                    } else {
                        continuation.resume(throwing: CommonRequesterError.requestFailed)
                    }
                }
            }
        } onCancel: {
            taskBox.task?.cancel()
        }
    }
    
    @discardableResult
    public static func requestSSE(
        _ request: URLRequest,
        onEvent: @escaping (String) -> Void,
        completion: @escaping (Error?) -> Void
    ) -> CancellableTask {
        let client = SSEClient(request: request)
        let task = ClosureCancellableTask {
            client.cancel()
        }
        
        client.onEvent = { event in
            deliver {
                onEvent(event)
            }
        }
        
        client.onComplete = { error in
            defer { task.finish() }
            deliver {
                completion(error)
            }
        }
        
        client.start()
        return task
    }
    
    public static func requestSSE(
        _ request: URLRequest
    ) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            let taskBox = CancellableTaskBox()
            
            taskBox.task = requestSSE(
                request,
                onEvent: { event in
                    continuation.yield(event)
                },
                completion: { error in
                    if let error {
                        continuation.finish(throwing: error)
                    } else {
                        continuation.finish()
                    }
                }
            )
            
            continuation.onTermination = { @Sendable _ in
                taskBox.task?.cancel()
            }
        }
    }
    
    private static func deliver(_ block: @escaping () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.async {
                block()
            }
        }
    }
}
