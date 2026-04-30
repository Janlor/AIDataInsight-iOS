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
        let wrapper = NetworkCancellableTask()
        let cancellable = ResponseModel<T>.requestable(
            target,
        ) { response, error in
            defer { wrapper.finish() }
            deliver {
                completion(response?.data, error)
            }
        }
        
        wrapper.bind(cancellable)
        return wrapper
    }
    
    @discardableResult
    public static func requestVoid(
        _ target: CustomTargetType,
        completion: @escaping (Bool, Error?) -> Void
    ) -> CancellableTask {
        
        let wrapper = NetworkCancellableTask()
        
        let cancellable = ResponseModel<AnyCodable>.requestable(
            target
        ) { response, error in
            defer { wrapper.finish() }
            
            deliver {
                let success = (error == nil) && (response?.code == 200)
                completion(success, error)
            }
        }
        
        wrapper.bind(cancellable)
        return wrapper
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
