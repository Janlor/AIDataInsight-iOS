//
//  AppDelegate.swift
//  AppAppLaunch
//
//  Created by Janlor on 2024/10/23.
//

import Foundation
import UIKit
import AppLaunch
import Router
import ProtocolAI
import BaseUI

/// 组件名称
let mircoAppModuleName = "ModuleAI"
class AppDelegate: UIResponder, AppDelegateModule {

    var moduleName: String { mircoAppModuleName }

    func load(_ window: UIWindow?) {
        let vc = Router.target(to: ProtocolAI.self)
        window?.rootViewController = BaseNavigationController(rootViewController: vc ?? UIViewController())
        window?.makeKeyAndVisible()
    }
    
    func applicationHighPriority(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        Router.register(key: ProtocolAI.self, module: ModuleAIRouter())
    }
}

// 注册
extension AppForwarder {
    @objc dynamic func app_entry_ModuleAI() {
        entry {
            AppDelegate()
        }
    }
}
