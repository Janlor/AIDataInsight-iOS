//
//  LoginRouter.swift
//  LibraryCommon
//
//  Created by Janlor on 4/22/26.
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
