//
//  UIViewControllerConstants.swift
//  LibraryCommon
//
//  Created by Janlor on 2024/5/22.
//

import UIKit

public extension UIViewController {
    
    /// Height of status bar
    var appStatusBarHeight: CGFloat {
        if #available(iOS 13.0, *) {
            if let window = UIApplication.shared.windows.first,
               let height = window.windowScene?.statusBarManager?.statusBarFrame.size.height {
                return height
            }
        }
        return 20.0
    }
    
    /// 最近的 navigationController（向上和向下都能找，带循环保护）
    private var nearestNavigationController: UINavigationController? {
        return findNearestNavigationController(visited: .init())
    }
    
    private func findNearestNavigationController(visited: Set<ObjectIdentifier>) -> UINavigationController? {
        let id = ObjectIdentifier(self)
        guard !visited.contains(id) else { return nil }
        var newVisited = visited
        newVisited.insert(id)
        
        if let nav = navigationController {
            return nav
        }
        if let nav = presentingViewController?.findNearestNavigationController(visited: newVisited) {
            return nav
        }
        if let nav = presentedViewController?.findNearestNavigationController(visited: newVisited) {
            return nav
        }
        return nil
    }
    
    /// Height of navigation bar
    var appNavigationBarHeight: CGFloat {
        nearestNavigationController?.navigationBar.frame.size.height ?? 44.0
    }
    
    /// Height of status bar + navigation bar
    var appTopBarHeight: CGFloat {
        appStatusBarHeight + appNavigationBarHeight
    }
    
    /// Height of tabBar (Include safe area bottom insets)
    var appTabBarHeight: CGFloat {
        tabBarController?.tabBar.frame.size.height ?? 49.0
    }
}
