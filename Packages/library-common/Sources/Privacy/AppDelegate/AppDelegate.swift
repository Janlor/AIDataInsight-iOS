//
//  AppDelegate.swift
//  Account
//
//  Created by Janlor on 2024/5/22.
//

import UIKit
import PrivacyProtocol
import Router
import AppLaunch

/// 组件名称
let mircoAppModuleName = "Privacy"

class AppDelegate: UIResponder, AppDelegateModule {

    var moduleName: String { mircoAppModuleName }
    
    var tokens: [NSObjectProtocol] = []
        
    var window: UIWindow?
    
    func load(_ window: UIWindow?) {
        self.window = window
    }
    
    func applicationHighPriority(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        Router.register(key: PrivacyProtocol.self, module: PrivacyPolicyRouter.self)
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
//        Router.perform(key: PrivacyProtocol.self)?.showPolicyIfNeeded()
    }
}

private extension AppForwarder {
    @objc dynamic func app_entry_Privacy() {
        entry {
            AppDelegate()
        }
    }
}
