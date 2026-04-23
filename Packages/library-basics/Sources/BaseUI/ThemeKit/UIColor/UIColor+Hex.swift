//
//  UIColor+Hex.swift
//  ThemeKit
//
//  Created by Janlor on 4/22/26.
//

import UIKit

public extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexSanitized.hasPrefix("#") {
            hexSanitized.removeFirst()
        }
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let r, g, b, a: CGFloat
        
        switch hexSanitized.count {
        case 6:
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255
            b = CGFloat(rgb & 0x0000FF) / 255
            a = 1.0
        case 8:
            a = CGFloat((rgb & 0xFF000000) >> 24) / 255
            r = CGFloat((rgb & 0x00FF0000) >> 16) / 255
            g = CGFloat((rgb & 0x0000FF00) >> 8) / 255
            b = CGFloat(rgb & 0x000000FF) / 255
        default:
            r = 1; g = 1; b = 1; a = 1
        }
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
    
    convenience init(light: UIColor, dark: UIColor, elevated: UIColor) {
        if #available(iOS 13.0, tvOS 13.0, *) {
            self.init(dynamicProvider: {
                $0.userInterfaceStyle == .dark
                ? ($0.userInterfaceLevel == .elevated ? elevated : dark)
                : light
            })
        } else {
            self.init(cgColor: light.cgColor)
        }
    }
}
