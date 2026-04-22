//
//  UIVIew+Corner.swift
//  LibraryBasics
//
//  Created by Janlor on 2025/9/26.
//

import UIKit

public enum ViewCornerStyle: Hashable {
    case none       // 无圆角
    case small      // base 4
    case medium     // base 8
    case large      // base 12
    case xLarge     // base 18
    case custom(CGFloat)
    
    /// 基准值映射
    public var baseValue: CGFloat {
        switch self {
        case .none: return 0
        case .small: return 4
        case .medium: return 8
        case .large: return 12
        case .xLarge: return 18
        case .custom(let v): return max(0, v)
        }
    }
    
    public init(rawValue: CGFloat) {
        switch rawValue {
        case 0: self = .none
        case 4: self = .small
        case 8: self = .medium
        case 12: self = .large
        case 18: self = .xLarge
        default: self = .custom(rawValue)
        }
    }
    
    /// resolve semantic base -> actual radius according to environment (traitCollection, idiom, etc.)
    public func resolved() -> CGFloat {
        var scale: CGFloat = 1.0
//            let trait = self.traitCollection
//
//            // example strategy — 可按需修改 / 拓展
//            if trait.userInterfaceIdiom == .pad {
//                scale *= 1.5
//            }
//            if trait.horizontalSizeClass == .regular {
//                scale *= 1.25
//            }
//            // 可以在这里加入对 contentSizeCategory / accessibility 的调整
        
        if #available(iOS 26.0, *), LiquidGlass.isEnabled {
            scale *= 3.0
        }
        
        return min(baseValue * scale, 22.0)
    }
}

public extension UIView {
    
    // MARK: - Capsule
    /// 应用“胶囊”语义的圆角
    ///
    /// - Parameters:
    ///   - style: ViewCornerStyle?，传 nil 表示随高度（height/2）的 capsule（注意 bounds 必须可用）
    func applyCapsule(_ style: ViewCornerStyle? = nil) {
        // resolved candidate radius: either semantic value or height/2 when style == nil
        func resolvedCandidate() -> CGFloat {
            if let s = style {
                return s.resolved()
            } else {
                let h = bounds.height
                return h > 0 ? (h / 2.0) : 0.0
            }
        }
        
        if #available(iOS 26.0, *), LiquidGlass.isEnabled {
            if style == .none {
                self.cornerConfiguration = .corners(radius: .fixed(0))
            } else if let s = style {
                // 使用 maximumRadius: Double?
                let maxR = Double(s.resolved())
                self.cornerConfiguration = .capsule(maximumRadius: maxR)
            } else {
                // style == nil: 让系统根据几何自动处理 capsule
                self.cornerConfiguration = .capsule()
            }
        } else {
            // iOS < 26: 使用 CALayer 的 cornerRadius + maskedCorners
            let r = resolvedCandidate()
            self.layer.cornerRadius = r
        }
        self.layer.masksToBounds = true
    }
    
    // MARK: - Fixed Corners
    
    /// 应用固定（语义）圆角到指定角位
    /// - Parameters:
    ///   - style: 非 nil 的 ViewCornerStyle
    func applyCorner(_ style: ViewCornerStyle) {
        let r = style.baseValue
        
        if #available(iOS 26.0, *), LiquidGlass.isEnabled {
            self.cornerConfiguration = UICornerConfiguration.corners(radius: .fixed(Double(r)))
        } else {
            self.layer.cornerRadius = r
        }
        self.layer.masksToBounds = true
    }
    
    // MARK: - Edges
    
    /// 顶部和底部不同圆角
    /// iOS 26 以下版本不支持单独设置某个角的圆角大小，只能通过最大值来设置
    func applyEdges(top topStyle: ViewCornerStyle,
                    bottom bottomStyle: ViewCornerStyle) {
        let top = topStyle.resolved()
        let bottom = bottomStyle.resolved()
        
        if #available(iOS 26.0, *), LiquidGlass.isEnabled {
            self.cornerConfiguration = .uniformEdges(
                topRadius: .fixed(top),
                bottomRadius: .fixed(bottom)
            )
        } else {
            self.layer.cornerRadius = max(top, bottom)
            self.layer.maskedCorners = [
                .layerMinXMinYCorner, .layerMaxXMinYCorner,
                .layerMinXMaxYCorner, .layerMaxXMaxYCorner
            ]
        }
        self.layer.masksToBounds = true
    }
    
    /// 左右不同圆角
    /// iOS 26 以下版本不支持单独设置某个角的圆角大小，只能通过最大值来设置
    func applyEdges(left leftStyle: ViewCornerStyle,
                    right rightStyle: ViewCornerStyle) {
        let left = leftStyle.resolved()
        let right = rightStyle.resolved()
        
        if #available(iOS 26.0, *), LiquidGlass.isEnabled {
            self.cornerConfiguration = .uniformEdges(
                leftRadius: .fixed(left),
                rightRadius: .fixed(right)
            )
        } else {
            self.layer.cornerRadius = max(left, right)
            self.layer.maskedCorners = [
                .layerMinXMinYCorner, .layerMinXMaxYCorner,
                .layerMaxXMinYCorner, .layerMaxXMaxYCorner
            ]
        }
        self.layer.masksToBounds = true
    }
    
    /// 顶部相同圆角
    /// iOS 26 以下版本不支持单独设置某个角的圆角大小，只能通过最大值来设置
    func applyTopRadius(_ style: ViewCornerStyle,
                        bottomLeft: ViewCornerStyle? = nil,
                        bottomRight: ViewCornerStyle? = nil) {
        if #available(iOS 26.0, *), LiquidGlass.isEnabled {
            self.cornerConfiguration = .uniformTopRadius(
                .fixed(style.resolved()),
                bottomLeftRadius: bottomLeft.map { .fixed($0.resolved()) },
                bottomRightRadius: bottomRight.map { .fixed($0.resolved()) }
            )
        } else {
            self.layer.cornerRadius = style.resolved()
            self.layer.maskedCorners = [
                .layerMinXMinYCorner, .layerMaxXMinYCorner
            ]
            if let bl = bottomLeft {
                self.layer.cornerRadius = max(self.layer.cornerRadius, bl.resolved())
                self.layer.maskedCorners.insert(.layerMinXMaxYCorner)
            }
            if let br = bottomRight {
                self.layer.cornerRadius = max(self.layer.cornerRadius, br.resolved())
                self.layer.maskedCorners.insert(.layerMaxXMaxYCorner)
            }
        }
        self.layer.masksToBounds = true
    }
    
    /// 底部相同圆角
    /// iOS 26 以下版本不支持单独设置某个角的圆角大小，只能通过最大值来设置
    func applyBottomRadius(_ style: ViewCornerStyle,
                           topLeft: ViewCornerStyle? = nil,
                           topRight: ViewCornerStyle? = nil) {
        if #available(iOS 26.0, *), LiquidGlass.isEnabled {
            self.cornerConfiguration = .uniformBottomRadius(
                .fixed(style.resolved()),
                topLeftRadius: topLeft.map { .fixed($0.resolved()) },
                topRightRadius: topRight.map { .fixed($0.resolved()) }
            )
        } else {
            self.layer.cornerRadius = style.resolved()
            self.layer.maskedCorners = [
                .layerMinXMaxYCorner, .layerMaxXMaxYCorner
            ]
            if let tl = topLeft {
                self.layer.cornerRadius = max(self.layer.cornerRadius, tl.resolved())
                self.layer.maskedCorners.insert(.layerMinXMinYCorner)
            }
            if let tr = topRight {
                self.layer.cornerRadius = max(self.layer.cornerRadius, tr.resolved())
                self.layer.maskedCorners.insert(.layerMaxXMinYCorner)
            }
        }
        self.layer.masksToBounds = true
    }
    
    /// 左侧相同圆角
    /// iOS 26 以下版本不支持单独设置某个角的圆角大小，只能通过最大值来设置
    func applyLeftRadius(_ style: ViewCornerStyle,
                         topRight: ViewCornerStyle? = nil,
                         bottomRight: ViewCornerStyle? = nil) {
        if #available(iOS 26.0, *), LiquidGlass.isEnabled {
            self.cornerConfiguration = .uniformLeftRadius(
                .fixed(style.resolved()),
                topRightRadius: topRight.map { .fixed($0.resolved()) },
                bottomRightRadius: bottomRight.map { .fixed($0.resolved()) }
            )
        } else {
            self.layer.cornerRadius = style.resolved()
            self.layer.maskedCorners = [
                .layerMinXMinYCorner, .layerMaxXMinYCorner
            ]
            if let tr = topRight {
                self.layer.cornerRadius = max(self.layer.cornerRadius, tr.resolved())
                self.layer.maskedCorners.insert(.layerMinXMaxYCorner)
            }
            if let br = bottomRight {
                self.layer.cornerRadius = max(self.layer.cornerRadius, br.resolved())
                self.layer.maskedCorners.insert(.layerMaxXMaxYCorner)
            }
        }
        self.layer.masksToBounds = true
    }
    
    /// 右侧相同圆角
    /// iOS 26 以下版本不支持单独设置某个角的圆角大小，只能通过最大值来设置
    func applyRightRadius(_ style: ViewCornerStyle,
                          topLeft: ViewCornerStyle? = nil,
                          bottomLeft: ViewCornerStyle? = nil) {
        if #available(iOS 26.0, *), LiquidGlass.isEnabled {
            self.cornerConfiguration = .uniformRightRadius(
                .fixed(style.resolved()),
                topLeftRadius: topLeft.map { .fixed($0.resolved()) },
                bottomLeftRadius: bottomLeft.map { .fixed($0.resolved()) }
            )
        } else {
            self.layer.cornerRadius = style.resolved()
            self.layer.maskedCorners = [
                .layerMinXMaxYCorner, .layerMaxXMaxYCorner
            ]
            if let tl = topLeft {
                self.layer.cornerRadius = max(self.layer.cornerRadius, tl.resolved())
                self.layer.maskedCorners.insert(.layerMinXMinYCorner)
            }
            if let bl = bottomLeft {
                self.layer.cornerRadius = max(self.layer.cornerRadius, bl.resolved())
                self.layer.maskedCorners.insert(.layerMaxXMinYCorner)
            }
        }
        self.layer.masksToBounds = true
    }
}
