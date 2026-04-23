//
//  AppDelegate.swift
//  Account
//
//  Created by Janlor on 4/22/26.
//

import UIKit
import SettingProtocol
import Router
import AppLaunch

/// 组件名称
let mircoAppModuleName = "Setting"

class AppDelegate: UIResponder, AppDelegateModule {

    var moduleName: String { mircoAppModuleName }
    
    var tokens: [NSObjectProtocol] = []
        
    var window: UIWindow?
    
    func load(_ window: UIWindow?) {
        self.window = window
    }
    
    func applicationHighPriority(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        Router.register(key: SettingProtocol.self, module: SettingRouter.self)
    }
}

private extension AppForwarder {
    @objc dynamic func app_entry_Setting() {
        entry {
            AppDelegate()
        }
    }
}
