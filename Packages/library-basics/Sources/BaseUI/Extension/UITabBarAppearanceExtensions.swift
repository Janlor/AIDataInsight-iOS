//
//  UITabBarAppearanceExtensions.swift
//  LibraryCommon
//
//  Created by Janlor on 4/22/26.
//

import UIKit
import ObjectiveC.runtime

@available(iOS 13.0, *)
public extension UITabBarAppearance {
    
    @discardableResult
    @objc override func normal(backgroundColor: UIColor = .white, background image: UIImage? = nil) -> Self {
        super.normal(backgroundColor: backgroundColor, background: image)
        stackedLayoutAppearance.normal.normal()
        stackedLayoutAppearance.selected.selected()
        inlineLayoutAppearance.normal.normal()
        inlineLayoutAppearance.selected.selected()
        compactInlineLayoutAppearance.normal.normal()
        compactInlineLayoutAppearance.selected.selected()
        return self
    }
    
    @discardableResult
    @objc override func transparency() -> Self {
        super.transparency()
        stackedLayoutAppearance.normal.normal()
        stackedLayoutAppearance.selected.selected()
        inlineLayoutAppearance.normal.normal()
        inlineLayoutAppearance.selected.selected()
        compactInlineLayoutAppearance.normal.normal()
        compactInlineLayoutAppearance.selected.selected()
        return self
    }
    
}

private var appBackgRoundImageDefalutKey: Void?
private var appStateSignalKey: Void?
public extension UINavigationBar {
    
    private var appBackgRoundImageDefalut: UIImage? {
        get {
            objc_getAssociatedObject(self, &appBackgRoundImageDefalutKey) as? UIImage
        }
        
        set {
            objc_setAssociatedObject(self, &appBackgRoundImageDefalutKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private enum State {
        case normal, transparency
    }
    
    private var appStateSignal: State {
        get {
            (objc_getAssociatedObject(self, &appStateSignalKey) as? State) ?? .normal
        }
        
        set {
            objc_setAssociatedObject(self, &appStateSignalKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    @discardableResult
    func normal(backgroundColor: UIColor = .white, background image: UIImage? = nil) -> Self {
        barTintColor = backgroundColor
        appStateSignal = .normal
        setBackgroundImage(image, for: .default)
//        shadowImage = .clear
        // 文本 按钮
        titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.theme.accent,
            NSAttributedString.Key.font: UIFont.theme.headline
        ]
        
        return self
    }
    
    @discardableResult
    func transparency() -> Self {
        barTintColor = .clear
        if appStateSignal == .normal {
            appStateSignal = .transparency
            appBackgRoundImageDefalut = backgroundImage(for: .default)
        }
//        setBackgroundImage(.clear, for: .default)
//        shadowImage = .clear
        // 文本 按钮
        titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.theme.accent,
            NSAttributedString.Key.font: UIFont.theme.headline
        ]
        return self
    }
}
