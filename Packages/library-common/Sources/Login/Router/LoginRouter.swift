//
//  LoginRouter.swift
//  LibraryCommon
//
//  Created by Janlor on 2022/1/26.
//

import UIKit
import LoginProtocol
import AccountProtocol
import Router
import Networking

struct LoginRouter: RouterService {

    init(){}
    
}

extension LoginRouter: RouterDestination {
    func to(_ arg: [AnyHashable: Any]?,
            _ closure: ((_ event: Any, _ arg: [AnyHashable: Any]?) -> Void)?) -> UIViewController {
        return LoginViewController()
    }
}

extension LoginRouter: LoginProtocol {
    /// 刷新 token
    func refresh(_ token: String, _ reslut: @escaping BoolResultClosure) -> CancellableTask {
        let target = OAuthApi.refresh(token)
        let task = ResponseModel<OAuthModel>.requestable(target) { response, error in
            guard error == nil, let oauth = response?.data else {
                reslut(false, error?.localizedDescription ?? NSLocalizedString("未知错误", bundle: .module, comment: ""))
                return
            }
            Router.perform(key: AccountProtocol.self)?.update(account: oauth)
            reslut(true, nil)
        }
        return NetworkCancellableTask(cancellable: task)
    }
    
    func refresh(_ token: String) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            refresh(token) { success, message in
                if success {
                    continuation.resume()
                } else {
                    let error = NSError(
                        domain: "LoginRouter.refresh",
                        code: 1,
                        userInfo: [NSLocalizedDescriptionKey: message ?? NSLocalizedString("未知错误", bundle: .module, comment: "")]
                    )
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /// 退出登录
    func logout(_ reslut: @escaping BoolResultClosure) {
        let target = OAuthApi.logout
        ResponseModel<EmptyModel>.requestable(target) { response, error in
            guard error == nil else {
                reslut(false, error?.localizedDescription ?? NSLocalizedString("未知错误", bundle: .module, comment: ""))
                return
            }
            reslut(true, nil)
        }
    }
    
    func logout() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            logout { success, message in
                if success {
                    continuation.resume()
                } else {
                    let error = NSError(
                        domain: "LoginRouter.logout",
                        code: 1,
                        userInfo: [NSLocalizedDescriptionKey: message ?? NSLocalizedString("未知错误", bundle: .module, comment: "")]
                    )
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

public class NetworkCancellableTask: CancellableTask {
    private let cancellable: Cancellable

    public init(cancellable: Cancellable) {
        self.cancellable = cancellable
    }

    public var isCancelled: Bool {
        cancellable.isCancelled
    }
    
    public func cancel() {
        cancellable.cancel()
    }
}
