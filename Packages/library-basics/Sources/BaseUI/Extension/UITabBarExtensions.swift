//
//  UITabBarExtensions.swift
//  LibraryCommon
//
//  Created by Janlor on 4/22/26.
//

import UIKit
import ObjectiveC.runtime

private var appTabBarBackgRoundImageDefalutKey: Void?
private var appTabBarShadowImageKey: Void?
private var appTabBarStateSignalKey: Void?
public extension UITabBar {
    
    private var appBackgRoundImageDefalut: UIImage? {
        get {
            objc_getAssociatedObject(self, &appTabBarBackgRoundImageDefalutKey) as? UIImage
        }
        
        set {
            objc_setAssociatedObject(self, &appTabBarBackgRoundImageDefalutKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var appShadowImage: UIImage? {
        get {
            objc_getAssociatedObject(self, &appTabBarShadowImageKey) as? UIImage
        }
        
        set {
            objc_setAssociatedObject(self, &appTabBarShadowImageKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private enum State {
        case normal, transparency
    }
    
    private var appStateSignal: State {
        get {
            (objc_getAssociatedObject(self, &appTabBarStateSignalKey) as? State) ?? .normal
        }
        
        set {
            objc_setAssociatedObject(self, &appTabBarStateSignalKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    @discardableResult
    func normal(backgroundColor: UIColor = .white, background image: UIImage? = nil) -> Self {
        /// 设置背景色
        barTintColor = backgroundColor
        /// 设置当前Appearance的状态
        appStateSignal = .normal
        /// 设置普通状态下的背景图片为系统提供的默认值或为透明状态下自定义的默认值
        backgroundImage = image
        /// 设置普通状态下的阴影图片为系统提供的默认值为透明状态下自定义的默认值
//        shadowImage = .clear
        
        return self
    }
    
    @discardableResult
    func transparency() -> Self {
        /// 设置背景色为透明
        barTintColor = .clear
        if appStateSignal == .normal {
            /// 设置当前Appearance的状态
            appStateSignal = .transparency
            /// 记录透明状态下的背景图片为系统提供的默认值
            appBackgRoundImageDefalut = backgroundImage
            /// 记录透明状态下的阴影图片为系统提供的默认值
            appShadowImage = shadowImage
        }
        /// 设置透明状态下的背景图片为自定义值
        backgroundImage = nil
        /// 设置透明状态下的阴影图片为自定义值
        shadowImage = nil
        return self
    }
}
