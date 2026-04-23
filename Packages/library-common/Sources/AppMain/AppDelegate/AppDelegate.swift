//
//  AppDelegate.swift
//  Account
//
//  Created by Janlor on 4/22/26.
//

import UIKit
import AccountProtocol
import LoginProtocol
import ProtocolAI
import BaseUI
import Router
import AppLaunch
import SwifterSwift

/// 组件名称
let mircoAppModuleName = "AppMain"

class AppDelegate: UIResponder, AppDelegateModule {

    var moduleName: String { mircoAppModuleName }
    
    var tokens: [NSObjectProtocol] = []
        
    var window: UIWindow?
    
    func load(_ window: UIWindow?) {
        self.window = window
        window?.rootViewController = rootViewController()
        window?.makeKeyAndVisible()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        addNotifications()
        setupAppearance()
        return true
    }
    
    func addNotifications() {
        /// 登录
        let token_0 = NotificationCenter.default.addObserver(forName: .sessionReady, object: nil, queue: .main) {[weak self] _ in
            self?.changeRootViewController()
        }
        tokens.append(token_0)
        
        /// 退出登录
        let token_1 = NotificationCenter.default.addObserver(forName: .logoutSucceed, object: nil, queue: .main) {[weak self] noti in
            Router.perform(key: AccountProtocol.self)?.remove()
            if let msg = noti.userInfo?["msg"] as? String {
                ProgressHUD.showError(withStatus: msg)
            }
            self?.changeRootViewController()
        }
        tokens.append(token_1)
    }
    
    func setupAppearance() {
        UITextView.appearance().tintColor = .theme.accent
        UITextField.appearance().tintColor = .theme.accent
        UITableView.appearance().tintColor = .theme.accent
        UICollectionView.appearance().tintColor = .theme.accent
    }
    
    deinit {
        for token in tokens {
            NotificationCenter.default.removeObserver(token)
        }
    }
}

extension AppDelegate {
    func rootViewController() -> UIViewController? {
        let isLogin = Router.perform(key: AccountProtocol.self)?.isLogin ?? false
        if isLogin {
            let vc = Router.target(to: ProtocolAI.self)!
//            let nav = BaseNavigationController(rootViewController: vc)
            return vc
        }
        guard let vc = Router.target(to: LoginProtocol.self) else { return nil }
        let nav = BaseNavigationController(rootViewController: vc)
        return nav
    }
    
    private static var isSwitchingRootVC = false
    
    func changeRootViewController() {
        guard let window = window else { return }
        guard let target = rootViewController() else { return }

        let current = window.rootViewController

        // 类型相同则不切
        if type(of: current) == type(of: target) {
            return
        }

        // 防止多次触发
        guard !Self.isSwitchingRootVC else { return }
        Self.isSwitchingRootVC = true

        window.switchRootViewController(to: target) {
            Self.isSwitchingRootVC = false
        }
    }

}

private extension AppForwarder {
    @objc dynamic func app_entry_AppMain() {
        entry {
            AppDelegate()
        }
    }
}
