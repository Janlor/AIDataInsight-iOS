//
//  AppDelegate.swift
//  Account
//
//  Created by Janlor on 2024/5/22.
//

import UIKit
import AccountProtocol
import Router
import AppLaunch

/// 组件名称
let mircoAppModuleName = "Account"

class AppDelegate: UIResponder, AppDelegateModule {

    var moduleName: String { mircoAppModuleName }
    
    var tokens: [NSObjectProtocol] = []
        
    var window: UIWindow?
    
    func load(_ window: UIWindow?) {
        self.window = window
    }
    
    func applicationHighPriority(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        let router = AccountRouter()
        Router.register(key: AccountProtocol.self, module: router)
        Router.register(key: AccountSessionStore.self, module: router)
        Router.register(key: AccountUserStore.self, module: router)
        Router.register(key: AccountRemoteService.self, module: router)
        Router.register(key: AccountRouteService.self, module: router)
    }
}

private extension AppForwarder {
    @objc dynamic func app_entry_Account() {
        entry {
            AppDelegate()
        }
    }
}
