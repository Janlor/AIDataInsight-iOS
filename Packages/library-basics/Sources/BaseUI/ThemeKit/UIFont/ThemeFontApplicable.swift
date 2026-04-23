//
//  ThemeFontApplicable.swift
//  ThemeKit
//
//  Created by Janlor on 4/22/26.
//

import UIKit

public protocol ThemeFontApplicable {
    var themeFont: UIFont? { get set }
}

// MARK: - UILabel
private var labelFontKey: UInt8 = 0
extension UILabel: ThemeFontApplicable {
    public var themeFont: UIFont? {
        get {
            getAssociatedObject(self, &labelFontKey)
        }
        set {
            font = newValue
            adjustsFontForContentSizeCategory = ThemeManager.shared.isDynamicFontEnabled
            setRetainedAssociatedObject(self, &labelFontKey, newValue)
        }
    }
}

// MARK: - UITextField
private var fieldFontKey: UInt8 = 0
extension UITextField: ThemeFontApplicable {
    public var themeFont: UIFont? {
        get {
            getAssociatedObject(self, &fieldFontKey)
        }
        set {
            font = newValue
            adjustsFontForContentSizeCategory = ThemeManager.shared.isDynamicFontEnabled
            setRetainedAssociatedObject(self, &fieldFontKey, newValue)
        }
    }
}

// MARK: - UITextView
private var textViewFontKey: UInt8 = 0
extension UITextView: ThemeFontApplicable {
    public var themeFont: UIFont? {
        get {
            getAssociatedObject(self, &textViewFontKey)
        }
        set {
            font = newValue
            adjustsFontForContentSizeCategory = ThemeManager.shared.isDynamicFontEnabled
            setRetainedAssociatedObject(self, &textViewFontKey, newValue)
        }
    }
}
