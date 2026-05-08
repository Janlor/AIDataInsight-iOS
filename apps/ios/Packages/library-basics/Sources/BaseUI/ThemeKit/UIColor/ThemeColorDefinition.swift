//
//  ThemeColorDefinition.swift
//  ThemeKit
//
//  Created by Janlor on 2025/8/5.
//

import UIKit

@available(iOS 13.0, *)
public struct ThemeColorDefinition: Codable {
    let light: String
    let dark: String?
    let elevated: String?

    func uiColor(for trait: UITraitCollection = .current) -> UIColor {
        let lightColor = UIColor(hex: light)
        let darkColor = UIColor(hex: dark ?? light)
        let elevatedColor = UIColor(hex: elevated ?? dark ?? light)
        return UIColor(light: lightColor, dark: darkColor, elevated: elevatedColor)
    }
}
