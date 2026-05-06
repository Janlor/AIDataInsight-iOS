//
//  DefaultAccountRemoteService.swift
//  LibraryBasics
//
//  Created by OpenAI on 2025/2/14.
//

import Foundation
import UIKit
import Router
import AccountProtocol
import Networking

final class DefaultAccountRemoteService: RouterDestination, AccountRemoteService {
    private let accountUserStore: AccountUserStore

    init(accountUserStore: AccountUserStore) {
        self.accountUserStore = accountUserStore
    }

    func to(_ arg: [AnyHashable : Any]?, _ closure: ((Any, [AnyHashable : Any]?) -> Void)?) -> UIViewController {
        UIViewController()
    }

    func getUserInfo<T>(_ reslut: @escaping (T?, String?) -> Void) where T : UserInfo, T : Codable {
        let target = AccountApi.getUserInfo
        ResponseModel<T>.requestable(target) { [accountUserStore] response, error in
            guard error == nil, let model = response?.data else {
                reslut(nil, error?.localizedDescription ?? NSLocalizedString("未知错误", bundle: .module, comment: ""))
                return
            }
            accountUserStore.updateUser(model)
            reslut(model, nil)
        }
    }

    func getMenuTree<T>(_ reslut: @escaping ([T]?, String?) -> Void) where T : MenuProtocol, T : Codable {
        let target = AccountApi.menuTree
        ResponseModel<[T]>.requestable(target) { [accountUserStore] response, error in
            guard error == nil, let models = response?.data else {
                reslut(nil, error?.localizedDescription ?? NSLocalizedString("未知错误", bundle: .module, comment: ""))
                return
            }
            accountUserStore.update(menus: models)
            reslut(models, nil)
        }
    }
}
