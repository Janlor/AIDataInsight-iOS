//
//  UIColor+Theme.swift
//  ThemeKit
//
//  Created by Janlor on 2025/8/5.
//

import UIKit

public extension UIColor {
    static let theme = ThemeColorPalette()
}

public struct ThemeColorPalette {
    
    // MARK: - Accent Colors

    public var accent: UIColor {
        ThemeManager.shared.color(for: .accent)
    }

    public var secondaryAccent: UIColor {
        ThemeManager.shared.color(for: .secondaryAccent)
    }

    // MARK: - Background

    public var background: UIColor {
        ThemeManager.shared.color(for: .background)
    }

    public var secondaryBackground: UIColor {
        ThemeManager.shared.color(for: .secondaryBackground)
    }

    public var tertiaryBackground: UIColor {
        ThemeManager.shared.color(for: .tertiaryBackground)
    }

    // MARK: - Grouped Background

    public var groupedBackground: UIColor {
        ThemeManager.shared.color(for: .groupedBackground)
    }

    public var secondaryGroupedBackground: UIColor {
        ThemeManager.shared.color(for: .secondaryGroupedBackground)
    }

    public var tertiaryGroupedBackground: UIColor {
        ThemeManager.shared.color(for: .tertiaryGroupedBackground)
    }

    // MARK: - Labels

    public var label: UIColor {
        ThemeManager.shared.color(for: .label)
    }

    public var secondaryLabel: UIColor {
        ThemeManager.shared.color(for: .secondaryLabel)
    }

    public var tertiaryLabel: UIColor {
        ThemeManager.shared.color(for: .tertiaryLabel)
    }

    public var quaternaryLabel: UIColor {
        ThemeManager.shared.color(for: .quaternaryLabel)
    }

    public var quinaryLabel: UIColor {
        ThemeManager.shared.color(for: .quinaryLabel)
    }

    // MARK: - Separator

    public var separator: UIColor {
        ThemeManager.shared.color(for: .separator)
    }

    // MARK: - Mark

    public var mark: UIColor {
        ThemeManager.shared.color(for: .mark)
    }
}
