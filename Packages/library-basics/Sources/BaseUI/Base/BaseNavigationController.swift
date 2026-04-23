//
//  BaseNavigationController.swift
//  LibraryCommon
//
//  Created by Janlor on 4/22/26.
//

import UIKit

open class BaseNavigationController: UINavigationController {
    
    open override var shouldAutorotate: Bool {
        return topViewController?.shouldAutorotate ?? false
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return topViewController?.preferredInterfaceOrientationForPresentation ?? .portrait
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return topViewController?.supportedInterfaceOrientations ?? .portrait
    }

    // MARK: - Override
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        let standardAppearance = navigationBar.standardAppearance.copy()
        configureAppearance(standardAppearance)
        standardAppearance.backgroundColor = .clear
        standardAppearance.backgroundEffect = nil
        navigationBar.standardAppearance = standardAppearance
        
        if let scrollEdgeAppearance = navigationBar.scrollEdgeAppearance?.copy() {
            configureAppearance(scrollEdgeAppearance)
            scrollEdgeAppearance.backgroundColor = .theme.secondaryGroupedBackground
            navigationBar.scrollEdgeAppearance = scrollEdgeAppearance
        }
        
        if #available(iOS 15.0, *), let compactScrollEdgeAppearance = navigationBar.compactScrollEdgeAppearance?.copy() {
            configureAppearance(compactScrollEdgeAppearance)
            compactScrollEdgeAppearance.backgroundColor = .theme.secondaryGroupedBackground
            navigationBar.compactScrollEdgeAppearance = compactScrollEdgeAppearance
        }
        
        navigationBar.tintColor = .theme.label
        navigationBar.isTranslucent = true
        view.backgroundColor = .theme.background
    }
    
    func configureAppearance(_ appearance: UINavigationBarAppearance) {
        if LiquidGlass.isEnabled {
            // do nothing
        } else {
            appearance.shadowImage = nil
            appearance.shadowColor = nil
        }
        
        // 标题字体和颜色
        let attributes: [NSAttributedString.Key : Any] = [
            .font: UIFont.theme.title2,
            .foregroundColor: UIColor.theme.label
        ]
        appearance.titleTextAttributes = attributes
        
        // 大标题字体和颜色
        let largeAttributes: [NSAttributedString.Key : Any] = [
            .font: UIFont.theme.title1,
            .foregroundColor: UIColor.theme.label
        ]
        appearance.largeTitleTextAttributes = largeAttributes
        
        // 返回图标
        let backImage = UIImage.imageNamed(for: "BaseUI_nav_back")
        appearance.setBackIndicatorImage(backImage, transitionMaskImage: backImage)
        let backButtonAppearance = appearance.backButtonAppearance
        // 返回文字
        backButtonAppearance.normal.titleTextAttributes = attributes
    }
    
    open override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        viewController.hidesBottomBarWhenPushed = viewControllers.first != nil
        super.pushViewController(viewController, animated: animated)
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        topViewController?.preferredStatusBarStyle ?? .default
    }
}
