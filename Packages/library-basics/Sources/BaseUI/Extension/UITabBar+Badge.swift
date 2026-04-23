//
//  UITabBar+Badge.swift
//  LibraryCommon
//
//  Created by Janlor on 4/22/26.
//

import UIKit

/// 这种自定义小红点也无法添加到 悬浮的 TabBar 上
//public extension UITabBar {
//    func addDot(at index: Int, color: UIColor = .red) {
//        guard let items = items, index < items.count else { return }
//        let itemView = subviews[index]
//        
//        // 避免重复添加
//        if itemView.viewWithTag(9999) != nil { return }
//        
//        let dotSize: CGFloat = 8
//        let dot = UIView(frame: CGRect(x: itemView.bounds.midX + 6,
//                                       y: 6,
//                                       width: dotSize,
//                                       height: dotSize))
//        dot.backgroundColor = color
//        dot.layer.cornerRadius = dotSize / 2
//        dot.tag = 9999
//        dot.autoresizingMask = [.flexibleLeftMargin, .flexibleBottomMargin]
//        itemView.addSubview(dot)
//    }
//    
//    func removeDot(at index: Int) {
//        guard let items = items, index < items.count else { return }
//        let itemView = subviews[index]
//        itemView.viewWithTag(9999)?.removeFromSuperview()
//    }
//}

public extension UITabBar {
    func setBadgeOnItem(at index: Int, number: Int) {
        guard let tabItems = self.items, index < tabItems.count else { return }
        let tabItem = tabItems[index]
        // iPadOS 18 悬浮式 TabBar 不支持自定义外观，无法显示小红点，直接用系统的 badge 显示数字。
        if #available(iOS 18.0, *), UIDevice.current.userInterfaceIdiom != .phone {
            tabItem.badgeValue = number.displayBadgeValue()
        } else {
            tabItem.badgeValue = number > 0 ? "●" : nil
        }
    }
}

public extension Int {
    func displayBadgeValue() -> String? {
        switch self {
        case ...0:
            return nil
        case 1...99:
            return String(self)
        default:
            return "99+"
        }
    }
}
