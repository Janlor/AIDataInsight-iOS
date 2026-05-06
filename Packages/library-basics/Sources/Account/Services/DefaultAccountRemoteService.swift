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
    private let networkExecutor: NetworkExecutor

    init(
        accountUserStore: AccountUserStore,
        networkExecutor: NetworkExecutor = NetworkExecutor()
    ) {
        self.accountUserStore = accountUserStore
        self.networkExecutor = networkExecutor
    }

    func to(_ arg: [AnyHashable : Any]?, _ closure: ((Any, [AnyHashable : Any]?) -> Void)?) -> UIViewController {
        UIViewController()
    }

    func getUserInfo<T>(_ reslut: @escaping (T?, String?) -> Void) where T : UserInfo, T : Codable {
        _Concurrency.Task {
            do {
                let response = try await networkExecutor.request(AccountApi.getUserInfo, as: ResponseModel<T>.self)
                guard let model = response.data else {
                    reslut(nil, response.msg ?? NSLocalizedString("未知错误", bundle: .module, comment: ""))
                    return
                }
                accountUserStore.updateUser(model)
                reslut(model, nil)
            } catch {
                reslut(nil, error.localizedDescription)
            }
        }
    }

    func getMenuTree<T>(_ reslut: @escaping ([T]?, String?) -> Void) where T : MenuProtocol, T : Codable {
        _Concurrency.Task {
            do {
                let response = try await networkExecutor.request(AccountApi.menuTree, as: ResponseModel<[T]>.self)
                guard let models = response.data else {
                    reslut(nil, response.msg ?? NSLocalizedString("未知错误", bundle: .module, comment: ""))
                    return
                }
                accountUserStore.update(menus: models)
                reslut(models, nil)
            } catch {
                reslut(nil, error.localizedDescription)
            }
        }
    }
}
