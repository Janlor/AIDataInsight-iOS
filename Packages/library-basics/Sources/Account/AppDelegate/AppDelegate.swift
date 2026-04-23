//
//  AppDelegate.swift
//  Account
//
//  Created by Janlor on 4/22/26.
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
        Router.register(key: AccountProtocol.self, module: AccountRouter())
    }
}

private extension AppForwarder {
    @objc dynamic func app_entry_Account() {
        entry {
            AppDelegate()
        }
    }
}
