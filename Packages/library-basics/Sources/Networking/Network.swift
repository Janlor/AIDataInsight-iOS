//
//  Network.swift
//  LibraryBasics
//
//  Created by Janlor on 2024/5/22.
//

import Foundation

/// 标准的网络服务
/// 当前作为兼容 façade 保留，对外 API 不变，内部已转发到新的 URLSession 执行链。
public struct Network {
    @discardableResult
    public static func requet(
        _ target: CustomTargetType,
        success successCallback: @escaping (Data) -> Void,
        failure failureCallback: @escaping ((NetworkError) -> Void)
    ) -> Cancellable {
        requet(
            target,
            success: successCallback,
            error: failureCallback,
            failure: failureCallback
        )
    }

    @discardableResult
    public static func requet(
        _ target: CustomTargetType,
        success successCallback: @escaping (Data) -> Void,
        error errorCallback: @escaping ((NetworkError) -> Void),
        failure failureCallback: @escaping ((NetworkError) -> Void)
    ) -> Cancellable {
        let task = _Concurrency.Task {
            do {
                let data = try await NetworkExecutor().requestData(target)
                successCallback(data)
            } catch let error as NetworkError {
                if error.isTimeout {
                    failureCallback(error)
                } else {
                    errorCallback(error)
                }
            } catch {
                let networkError = NetworkError.underlying(error, nil)
                if networkError.isTimeout {
                    failureCallback(networkError)
                } else {
                    errorCallback(networkError)
                }
            }
        }

        return TaskCancellable {
            task.cancel()
        }
    }
}
