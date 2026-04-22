//
//  UITabBarControllerExtensions.swift
//  LibraryCommon
//
//  Created by Janlor on 2024/5/22.
//

import UIKit

// MARK: 寻找控制器
@objc
public extension UITabBarController {
    
    @objc
    /// 获取tabbar被选择的控制器
    static func selectedViewController() -> UIViewController? {
        var windows: [UIWindow] = []
        if #available(iOS 15.0, *) {
            let scenes = UIApplication.shared.connectedScenes
            for scene in scenes {
                if case let windowScene as UIWindowScene = scene {
                    if windowScene.activationState != .unattached {
                        /// 15.0及以上，获取fromwindow
                        windows = windowScene.windows
                    }
                }
            }
        } else {
            windows = UIApplication.shared.windows
        }
        
        for window in windows {
            if case let tbvc as UITabBarController = window.rootViewController {
                return tbvc.selectedViewController
            }
        }
        return nil
    }
    
    @objc
    /// 获取tabbar被选择的导航控制器
    static func selectedNavigationController() -> UINavigationController? {
        selectedViewController() as? UINavigationController
    }
    
}
