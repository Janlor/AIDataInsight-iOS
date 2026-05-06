//
//  Network.swift
//  LibraryBasics
//
//  Created by Janlor on 2024/5/22.
//

import Foundation
import Moya

/// 标准的网络服务
/// 如果需要特殊的网络服务，请直接自己实现provider
public struct Network {
    /// 服务提供者
    /// 此处可以插入全局的拦截器
    public static let provider: MoyaProvider<CustomMultiTarget> = {
        // 插件数组
        var plugins: [PluginType] = [
            NetworkAuthPlugin()
        ]
        
#if DEBUG
        let loggerPlugin = NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
        plugins.append(loggerPlugin)
#endif
        return MoyaProvider<CustomMultiTarget>(
            endpointClosure: customEndpointMapping,
//            requestClosure: { endpoint, done in
//                do {
//                    var request = try endpoint.urlRequest()
//                    // 设置请求超时时间为300秒
//                    request.timeoutInterval = 300
//                    done(.success(request))
//                } catch {
//                    done(.failure(MoyaError.underlying(error, nil)))
//                }
//            },
            plugins: plugins
        )
    }()
    
    @discardableResult
    public static func requet(
        _ target: CustomTargetType,
        success successCallback: @escaping (Data) -> Void,
        failure failureCallback: @escaping ((NetworkError) -> Void)
    ) -> Cancellable {
        request(target: CustomMultiTarget(target),
                success: successCallback,
                error: { failureCallback($0) },
                failure: failureCallback)
    }
    
    @discardableResult
    public static func requet(
        _ target: CustomTargetType,
        success successCallback: @escaping (Data) -> Void,
        error errorCallback: @escaping ((NetworkError) -> Void),
        failure failureCallback: @escaping ((NetworkError) -> Void)
    ) -> Cancellable {
        request(target: CustomMultiTarget(target),
                success: successCallback,
                error: errorCallback,
                failure: failureCallback)
    }
    
    @discardableResult
    /// 标准的网络服务
    /// 如果需要特殊的网络服务，请直接调用全局provider，或者自己实现一个provider
    /// 自定义请求时，如果不是必要，请实现CustomTargetType协议，而不是实现Moya.TargetType协议。
    /// 因为默认baseURL、header等配置在CustomTargetType的默认实现中
    /// - Parameters:
    ///   - target: CustomMultiTarget
    ///   - successCallback: 包含 http code  200 ~ 399 的响应回调，可以认为服务器响应成功，
    ///                      但是不代表业务执行成功
    ///   - errorCallback: http code  200 ~ 399之外的响应回调，可以认为服务器响应失败；
    ///                    如果返回负值，则需要到AppCustomError中查看对应的自定义错误
    ///   - failureCallback: 网络失败，请求未到达服务器
    /// - Returns: Cancellable，用于取消请求
    private static func request(
        target: CustomMultiTarget,
        success successCallback: @escaping (Data) -> Void,
        error errorCallback: @escaping ((NetworkError) -> Void),
        failure failureCallback: @escaping ((NetworkError) -> Void)
    ) -> Cancellable {
        return provider.request(target) { result in
            switch result {
            case let .success(response):
                do {
                    let _ = try response.filterSuccessfulStatusAndRedirectCodes()
                    let decodedResponse = try NetworkDecoder.decode(ResponseModel<EmptyModel>.self, from: response.data)
                    if let code = decodedResponse.code {
                        switch code {
                        case 200:
                            successCallback(response.data)
                        case 401, 600: // 401未授权 600被顶下线
                            invalidAccessToken(msg: decodedResponse.msg)
                            errorCallback(.underlying(ResponseError.server(code, decodedResponse.msg), response))
                        case 402: // 402授权过期
                            handle402Response(decodedResponse: decodedResponse,
                                              target: target,
                                              successCallback: successCallback,
                                              errorCallback: errorCallback,
                                              failureCallback: failureCallback)
                        default:
                            errorCallback(.underlying(ResponseError.server(code, decodedResponse.msg), response))
                        }
                    } else {
                        successCallback(response.data)
                    }
                } catch MoyaError.statusCode(let response) {
                    errorCallback(.statusCode(response))
                } catch MoyaError.jsonMapping(let response) {
                    errorCallback(.jsonMapping(response))
                } catch {
                    errorCallback(.underlying(ResponseError.unknown, error as? Response))
                }
            case let .failure(error):
                failureCallback(error)
            }
        }
    }
    
    // MARK: 自动刷新 Token，并重试所有请求
    
    private static var isRefreshing = false
    private static var requestsToRetry: [(CustomMultiTarget, (Response) -> Void, ((NetworkError) -> Void), ((NetworkError) -> Void))] = []

    private static func handle402Response(
        decodedResponse: ResponseModel<EmptyModel>,
        target: CustomMultiTarget,
        successCallback: @escaping (Data) -> Void,
        errorCallback: @escaping ((NetworkError) -> Void),
        failureCallback: @escaping ((NetworkError) -> Void)
    ) {
        guard let refreshToken = NetworkDependencies.credentialProvider.refreshToken else {
            invalidAccessToken(msg: decodedResponse.msg)
            errorCallback(.underlying(NSError(domain: "", code: 401, userInfo: nil), nil))
            return
        }

        addRetryRequest(target: target, success: { response in
            do {
                let _ = try response.filterSuccessfulStatusAndRedirectCodes()
                let decodedResponse = try NetworkDecoder.decode(ResponseModel<EmptyModel>.self, from: response.data)
                if let code = decodedResponse.code {
                    switch code {
                    case 200:
                        successCallback(response.data)
                    default:
                        errorCallback(.underlying(ResponseError.server(code, decodedResponse.msg), response))
                    }
                } else {
                    successCallback(response.data)
                }
            } catch MoyaError.statusCode(let response) {
                errorCallback(.statusCode(response))
            } catch MoyaError.jsonMapping(let response) {
                errorCallback(.jsonMapping(response))
            } catch {
                errorCallback(.underlying(ResponseError.unknown, error as? Response))
            }
        }, error: errorCallback, failure: failureCallback)

        refreshTokenIfNeeded(refreshToken) { success in
            if success {
                retryRequests()
            } else {
                failPendingRequests()
            }
        }
    }

    private static func addRetryRequest(
        target: CustomMultiTarget,
        success: @escaping (Response) -> Void,
        error: @escaping ((NetworkError) -> Void),
        failure: @escaping ((NetworkError) -> Void)
    ) {
        requestsToRetry.append((target, success, error, failure))
    }

    private static func retryRequests() {
        requestsToRetry.forEach { target, success, errorCallback, failure in
            provider.request(target) { result in
                switch result {
                case let .success(response):
                    success(response)
                case let .failure(error):
                    failure(error)
                }
            }
        }
        requestsToRetry.removeAll()
    }

    private static func failPendingRequests() {
        requestsToRetry.forEach { _, _, error, _ in
            error(.underlying(NSError(domain: "", code: 401, userInfo: nil), nil))
        }
        requestsToRetry.removeAll()
    }
    
    private static var lastTokenRefreshTime: TimeInterval = 0 // 记录上次刷新时间
    private static let tokenRefreshInterval: TimeInterval = 10 // 10秒内不重复刷新
    private static func refreshTokenIfNeeded(_ refreshToken: String, completion: @escaping (Bool) -> Void) {
        let currentTime = Date().timeIntervalSince1970
        // 如果距离上次刷新时间不足10秒，直接返回
        guard currentTime - lastTokenRefreshTime > tokenRefreshInterval else {
            print("Token refresh skipped: Within \(tokenRefreshInterval) seconds")
            return
        }
        // 更新刷新时间并发起请求
        lastTokenRefreshTime = currentTime
        
        refreshTokenRequest(refreshToken) { success in
            if success {
                print("Token refreshed successfully")
            } else {
                print("Token refresh failed")
                // 如果刷新失败，清空刷新时间，允许后续再次尝试
                lastTokenRefreshTime = 0
            }
            completion(success)
        }
    }
    
    private static func refreshTokenRequest(_ refreshToken: String, completion: @escaping (Bool) -> Void) {
        let task = NetworkDependencies.tokenRefreshService.refreshToken(refreshToken) { succeed, error in
            completion(succeed == true && error == nil)
        }
        // 设置超时时间，防止网络卡住
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            if let task = task {
                task.cancel()
                print("Refresh token request timed out")
                completion(false)
            }
        }
    }
    
    static func invalidAccessToken(msg: String?) {
        NetworkDependencies.sessionInvalidationHandler.invalidateSession(message: msg)
    }
}
