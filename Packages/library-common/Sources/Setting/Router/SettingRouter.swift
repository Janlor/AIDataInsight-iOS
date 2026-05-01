//
//  SettingRouter.swift
//  Account
//
//  Created by Janlor on 2024/7/1.
//

import UIKit
import Router
import SettingProtocol
import BaseUI

struct SettingRouter: RouterService {
    
}

extension SettingRouter: RouterDestination {
    func to(_ arg: [AnyHashable : Any]?, _ closure: ((Any, [AnyHashable : Any]?) -> Void)?) -> UIViewController {
        let viewController = SettingViewController()
        let navigationController = BaseNavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .pageSheet
        return navigationController
    }
}

extension SettingRouter: SettingProtocol {
    func setupSetting(for viewController : UIViewController) {
        let tool = SettingToolView()
        tool.setupSetting(for: viewController)
        viewController.view.addSubview(tool) // 避免被释放
    }
}
