//
//  LiquidGlass.swift
//  LibraryBasics
//
//  Created by Janlor on 2025/9/28.
//

import Foundation

public enum LiquidGlass {
    /// 是否启用了 iOS 26 液态玻璃效果
    public static var isEnabled: Bool {
        guard #available(iOS 26.0, *) else {
            return false
        }
        // 读取 Info.plist 中的 UIDesignRequiresCompatibility
        guard let requiresCompatibility = Bundle.main.object(forInfoDictionaryKey: "UIDesignRequiresCompatibility") as? Bool else {
            // key 不存在时，系统默认为开启
            return true
        }
        // 值为 NO 时表示开启液态玻璃
        return requiresCompatibility == false
    }
}
