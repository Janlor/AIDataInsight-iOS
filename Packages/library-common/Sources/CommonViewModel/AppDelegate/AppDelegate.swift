//
//  AppDelegate.swift
//  Account
//
//  Created by Janlor on 4/22/26.
//

import UIKit
import AppLaunch
import Networking

/// 组件名称
let mircoAppModuleName = "CommonViewModel"

class AppDelegate: UIResponder, AppDelegateModule {

    var moduleName: String { mircoAppModuleName }
    
    var tokens: [NSObjectProtocol] = []
        
    var window: UIWindow?
    
    func load(_ window: UIWindow?) {
        self.window = window
    }
    
    func applicationHighPriority(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        NetworkMonitor.shared.setup(
            provider: NetworkReachabilityAdapter()
        )
    }
}

private extension AppForwarder {
    @objc dynamic func app_entry_CommonViewModel() {
        entry {
            AppDelegate()
        }
    }
}
