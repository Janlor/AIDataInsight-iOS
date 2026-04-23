//
//  UIWindowExtensions.swift
//  LibraryCommon
//
//  Created by Janlor on 4/22/26.
//

import UIKit

public extension AppWrapper where Base: UIWindow {
    static func currentViewController() -> UIViewController? {
        var windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        
        if windowScene == nil {
            windowScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundInactive }) as? UIWindowScene
        }
        
        // 找到当前激活的 windowScene
        guard let windowScene = windowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return nil
        }

        // 从 rootViewController 开始递归
        var topViewController = window.rootViewController
        while true {
            if let presented = topViewController?.presentedViewController {
                topViewController = presented
            } else if let nav = topViewController as? UINavigationController {
                topViewController = nav.topViewController
            } else if let tab = topViewController as? UITabBarController {
                topViewController = tab.selectedViewController
            } else if let split = topViewController as? UISplitViewController {
                topViewController = split.viewControllers.last
            } else {
                break
            }
        }
        return topViewController
    }
}

