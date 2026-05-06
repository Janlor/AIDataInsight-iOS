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

public protocol NetworkCredentialProvider {
    var accessToken: String? { get }
    var refreshToken: String? { get }
    var orgId: Int? { get }
}

public protocol TokenRefreshService {
    @discardableResult
    func refreshToken(_ token: String, completion: @escaping (Bool, String?) -> Void) -> Cancellable?
}

public protocol SessionInvalidationHandler {
    func invalidateSession(message: String?)
}

public enum NetworkDependencies {
    public static var credentialProvider: NetworkCredentialProvider = DefaultNetworkCredentialProvider()
    public static var tokenRefreshService: TokenRefreshService = DefaultTokenRefreshService()
    public static var sessionInvalidationHandler: SessionInvalidationHandler = DefaultSessionInvalidationHandler()
}

struct DefaultNetworkCredentialProvider: NetworkCredentialProvider {
    private var accountService: AccountSessionStore? {
        Router.perform(key: AccountSessionStore.self) ?? Router.perform(key: AccountProtocol.self)
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
        let target = OAuthApi.refresh(token)
        let task = ResponseModel<OAuthModel>.requestable(target) { response, error in
            guard error == nil, let oauth = response?.data else {
                completion(false, error?.localizedDescription ?? NSLocalizedString("未知错误", bundle: .module, comment: ""))
                return
            }

            let accountService = Router.perform(key: AccountSessionStore.self) ?? Router.perform(key: AccountProtocol.self)
            accountService?.update(account: oauth)
            completion(true, nil)
        }
        return task
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
