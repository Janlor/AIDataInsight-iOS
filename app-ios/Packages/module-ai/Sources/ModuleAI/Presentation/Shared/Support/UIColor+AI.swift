//
//  UIColor+AI.swift
//  ModuleAI
//
//  Created by Janlor on 2024/11/6.
//

#if canImport(UIKit)
import UIKit
import BaseUI

/// Dark Mode
public extension UIColor {
    
    /// AI 品牌色
    static let aiAccent = UIColor(appHex: 0x2F7BFF)
    
    /// 主文字颜色
    static let aiLabel = UIColor(
        light: UIColor(appHex: 0x111827),
        dark: UIColor(appHex: 0xF9FAFB)
    )
    
    /// 分割线颜色
    static let aiSeparator = UIColor(
        light: UIColor(appHex: 0xE5EAF3),
        dark: UIColor(appHex: 0x2B364C)
    )
}

#endif
