//
//  UIFont+Theme.swift
//  ThemeKit
//
//  Created by Janlor on 2025/8/5.
//

import UIKit

public extension UIFont {
    static let theme = ThemeFontPalette()
}

public struct ThemeFontPalette {
    public var largeTitle: UIFont { ThemeManager.shared.font(for: "largeTitle") }
    public var title1: UIFont { ThemeManager.shared.font(for: "title1") }
    public var title2: UIFont { ThemeManager.shared.font(for: "title2") }
    public var title3: UIFont { ThemeManager.shared.font(for: "title3") }
    public var title31: UIFont { ThemeManager.shared.font(for: "title31") }
    public var title4: UIFont { ThemeManager.shared.font(for: "title4") }
    public var headline: UIFont { ThemeManager.shared.font(for: "headline") }
    public var subhead: UIFont { ThemeManager.shared.font(for: "subhead") }
    public var body: UIFont { ThemeManager.shared.font(for: "body") }
    public var body1: UIFont { ThemeManager.shared.font(for: "body1") }
    public var body2: UIFont { ThemeManager.shared.font(for: "body2") }
    public var body3: UIFont { ThemeManager.shared.font(for: "body3") }
    public var footnote: UIFont { ThemeManager.shared.font(for: "footnote") }
    public var caption1: UIFont { ThemeManager.shared.font(for: "caption1") }
    public var caption2: UIFont { ThemeManager.shared.font(for: "caption2") }
}
