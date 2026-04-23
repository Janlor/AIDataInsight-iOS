//
//  Spacing.swift
//  Pods
//
//  Created by Janlor on 4/22/26.
//

import UIKit

// 设计稿宽度（375）
public let designWidth: CGFloat = 375.0
// 当前屏幕的宽度
public let screenWidth = UIScreen.main.bounds.width
// 计算当前屏幕宽度相对于设计稿宽度的比例
public let scaleFactor = screenWidth / designWidth
/// 传入一个 CGFloat 值，需要根据当前屏幕宽度进行缩放
public func scaledValue(for designValue: CGFloat) -> CGFloat {
    return designValue * min(scaleFactor, 1.3)
}

public struct Spacing {
    /// 4.0
    public static let xxSmall: CGFloat = 4.0
    /// 8.0
    public static let xSmall: CGFloat = 8.0
    /// 12.0
    public static let small: CGFloat = 12.0
    /// 16.0
    public static let medium: CGFloat = 16.0
    /// 24.0
    public static let large: CGFloat = 24.0
    /// 32.0
    public static let xLarge: CGFloat = 32.0
    /// 40.0
    public static let xxLarge: CGFloat = 40.0
    /// 48.0
    public static let xxxLarge: CGFloat = 48.0
}

public extension UIView {
    /// xxSmall 边距 4.0
    var xxsSpacing: CGFloat {
        Spacing.xxSmall
//        let spacingForSizeClass: [UIUserInterfaceSizeClass: CGFloat] = [
//            .compact: Spacing.xxSmall,
//            .regular: Spacing.xSmall
//        ]
//        return spacingForSizeClass[traitCollection.horizontalSizeClass] ?? Spacing.xxSmall
    }
    
    /// xSmall 边距 8.0
    var xsSpacing: CGFloat {
        Spacing.xSmall
//        let spacingForSizeClass: [UIUserInterfaceSizeClass: CGFloat] = [
//            .compact: Spacing.xSmall,
//            .regular: Spacing.small
//        ]
//        return spacingForSizeClass[traitCollection.horizontalSizeClass] ?? Spacing.xSmall
    }
    
    /// Small 边距 12.0
    var sSpacing: CGFloat {
        Spacing.small
//        let spacingForSizeClass: [UIUserInterfaceSizeClass: CGFloat] = [
//            .compact: Spacing.small,
//            .regular: Spacing.medium
//        ]
//        return spacingForSizeClass[traitCollection.horizontalSizeClass] ?? Spacing.small
    }
    
    /// Medium 边距 16.0
    var mSpacing: CGFloat {
        Spacing.medium
//        let spacingForSizeClass: [UIUserInterfaceSizeClass: CGFloat] = [
//            .compact: Spacing.medium,
//            .regular: Spacing.large
//        ]
//        return spacingForSizeClass[traitCollection.horizontalSizeClass] ?? Spacing.medium
    }
    
    /// Large 边距 24.0
    var lSpacing: CGFloat {
        Spacing.large
//        let spacingForSizeClass: [UIUserInterfaceSizeClass: CGFloat] = [
//            .compact: Spacing.large,
//            .regular: Spacing.xLarge
//        ]
//        return spacingForSizeClass[traitCollection.horizontalSizeClass] ?? Spacing.large
    }
    
    /// xLarge 边距 32.0
    var xlSpacing: CGFloat {
        Spacing.xLarge
//        let spacingForSizeClass: [UIUserInterfaceSizeClass: CGFloat] = [
//            .compact: Spacing.xLarge,
//            .regular: Spacing.xxLarge
//        ]
//        return spacingForSizeClass[traitCollection.horizontalSizeClass] ?? Spacing.xLarge
    }
    
    /// xxLarge 边距 40.0
    var xxlSpacing: CGFloat {
        Spacing.xxLarge
//        let spacingForSizeClass: [UIUserInterfaceSizeClass: CGFloat] = [
//            .compact: Spacing.xxLarge,
//            .regular: Spacing.xxxLarge
//        ]
//        return spacingForSizeClass[traitCollection.horizontalSizeClass] ?? Spacing.xxLarge
    }
}

public extension UIView {
    /// 边距
    @available(*, deprecated, renamed: "mSpacing", message: "padding has been renamed mSpacing.")
    var padding: CGFloat {
        mSpacing
    }
    
    /// 间距
    @available(*, deprecated, renamed: "sSpacing", message: "spacing has been renamed sSpacing.")
    var spacing: CGFloat {
        sSpacing
    }
}

public extension UIViewController {
    /// 边距
    @available(*, deprecated, renamed: "view.mSpacing", message: "padding has been renamed view.mSpacing.")
    var padding: CGFloat {
        view.mSpacing
    }
    
    /// 间距
    @available(*, deprecated, renamed: "view.sSpacing", message: "spacing has been renamed view.sSpacing.")
    var spacing: CGFloat {
        view.sSpacing
    }
}
