//
//  SettingRouter.swift
//  Account
//
//  Created by Janlor on 4/22/26.
//

import UIKit
import Router
import SettingProtocol

struct SettingRouter: RouterService {
    
}

extension SettingRouter: RouterDestination {
    func to(_ arg: [AnyHashable : Any]?, _ closure: ((Any, [AnyHashable : Any]?) -> Void)?) -> UIViewController {
        UIViewController()
    }
}

extension SettingRouter: SettingProtocol {
    func setupSetting(for viewController : UIViewController) {
        let tool = SettingToolView()
        tool.setupSetting(for: viewController)
        viewController.view.addSubview(tool) // 避免被释放
    }
}
