//
//  NetworkDependencies.swift
//  LibraryBasics
//
//  Created by OpenAI on 2025/2/14.
//

import Foundation
import Moya
import Router
import AccountProtocol

final class TaskCancellable: Cancellable {
    private let cancelClosure: () -> Void
    private(set) var isCancelled = false

    init(cancelClosure: @escaping () -> Void) {
        self.cancelClosure = cancelClosure
    }

    func cancel() {
        guard isCancelled == false else { return }
        isCancelled = true
        cancelClosure()
    }
}

public protocol NetworkCredentialProvider {
    var accessToken: String? { get }
    var refreshToken: String? { get }
    var orgId: Int? { get }
}

public protocol TokenRefreshService: Sendable {
    @discardableResult
    func refreshToken(_ token: String, completion: @escaping (Bool, String?) -> Void) -> Cancellable?
}

public protocol SessionInvalidationHandler: Sendable {
    func invalidateSession(message: String?)
}

public enum NetworkDependencies {
    private static let defaultTokenRefreshService = DefaultTokenRefreshService()

    public static var credentialProvider: NetworkCredentialProvider = DefaultNetworkCredentialProvider()
    public static var tokenRefreshService: TokenRefreshService = defaultTokenRefreshService {
        didSet {
            tokenRefreshCoordinator = TokenRefreshCoordinator(tokenRefreshService: tokenRefreshService)
        }
    }
    public static var tokenRefreshCoordinator: TokenRefreshCoordinator = TokenRefreshCoordinator(
        tokenRefreshService: defaultTokenRefreshService
    )
    public static var sessionInvalidationHandler: SessionInvalidationHandler = DefaultSessionInvalidationHandler()
}

struct DefaultNetworkCredentialProvider: NetworkCredentialProvider {
    private var accountService: AccountSessionStore? {
        Router.perform(key: AccountSessionStore.self)
    }

    var accessToken: String? {
        accountService?.accessToken
    }

    var refreshToken: String? {
        accountService?.refreshToken
    }

    var orgId: Int? {
        accountService?.orgId
    }
}

struct DefaultTokenRefreshService: TokenRefreshService {
    @discardableResult
    func refreshToken(_ token: String, completion: @escaping (Bool, String?) -> Void) -> Cancellable? {
        let task = _Concurrency.Task {
            do {
                let response = try await NetworkExecutor().request(OAuthApi.refresh(token), as: ResponseModel<OAuthModel>.self)
                guard let oauth = response.data else {
                    completion(false, response.msg ?? NSLocalizedString("未知错误", bundle: .module, comment: ""))
                    return
                }

                Router.perform(key: AccountSessionStore.self)?.update(account: oauth)
                completion(true, nil)
            } catch is CancellationError {
                completion(false, NSLocalizedString("未知错误", bundle: .module, comment: ""))
            } catch {
                completion(false, error.localizedDescription)
            }
        }

        return TaskCancellable {
            task.cancel()
        }
    }
}

struct DefaultSessionInvalidationHandler: SessionInvalidationHandler {
    func invalidateSession(message: String?) {
        DispatchQueue.main.async {
            var userInfo: [AnyHashable: Any]?
            if let message {
                userInfo = ["msg": message]
            }
            NotificationCenter.default.post(name: .logoutSucceed, object: nil, userInfo: userInfo)
        }
    }
}
