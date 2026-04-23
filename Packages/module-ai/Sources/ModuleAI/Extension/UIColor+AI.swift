//
//  UIColor+AI.swift
//  ModuleAI
//
//  Created by Janlor on 4/22/26.
//

#if canImport(UIKit)
import UIKit
import BaseUI

/// Dark Mode
public extension UIColor {
    
    static let aiAccent = UIColor(appHex: 0xAD131D)
    
    static let aiLabel = UIColor(
        light: UIColor(appHex: 0x452C3E),
        dark: UIColor(appHex: 0xBDA7B7)
    )
    
    /// 分割线颜色 EDEFF4 100%
    static let aiSeparator = UIColor(
        light: UIColor(appHex: 0xEDEFF4),
        dark: UIColor.clear
    )
}

#endif
