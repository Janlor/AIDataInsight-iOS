//
//  UINavigationBarAppearanceExtensions.swift
//  LibraryCommon
//
//  Created by Janlor on 2024/5/22.
//

import UIKit

@available(iOS 13.0, *)
public extension UINavigationBarAppearance {
    
    @discardableResult
    @objc override func normal(backgroundColor: UIColor = .white, background image: UIImage? = nil) -> Self {
        super.normal(backgroundColor: backgroundColor, background: image)
        // 文本 按钮
        titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.theme.secondaryAccent,
            NSAttributedString.Key.font: UIFont.theme.headline
        ]
        
        let buttonAppearance = UIBarButtonItemAppearance()
        
        /// barButtonItem的字体设置
        buttonAppearance.normal.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.theme.secondaryAccent,
            NSAttributedString.Key.font: UIFont.theme.caption2
        ]
        buttonAppearance.highlighted.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.red,
            NSAttributedString.Key.font: UIFont.theme.caption2
        ]
        buttonAppearance.disabled.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.gray,
            NSAttributedString.Key.font: UIFont.theme.caption2
        ]
        buttonAppearance.focused.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.green,
            NSAttributedString.Key.font: UIFont.theme.caption2
        ]
        
        let plainButton = buttonAppearance.copy()
        plainButton.configureWithDefault(for: .plain)
        self.buttonAppearance = plainButton
        
        let doneButton = buttonAppearance.copy()
        plainButton.configureWithDefault(for: .done)
        doneButtonAppearance = doneButton
        return self
    }
    
    @discardableResult
    @objc override func transparency() -> Self {
        super.transparency()
        // 文本 按钮
        titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.theme.accent,
            NSAttributedString.Key.font: UIFont.theme.headline
        ]
        
        let buttonAppearance = UIBarButtonItemAppearance()
        
        /// barButtonItem的字体设置
        buttonAppearance.normal.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.theme.secondaryAccent,
            NSAttributedString.Key.font: UIFont.theme.caption2
        ]
        buttonAppearance.highlighted.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.red,
            NSAttributedString.Key.font: UIFont.theme.caption2
        ]
        buttonAppearance.disabled.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.gray,
            NSAttributedString.Key.font: UIFont.theme.caption2
        ]
        buttonAppearance.focused.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.green,
            NSAttributedString.Key.font: UIFont.theme.caption2
        ]
        
        let plainButton = buttonAppearance.copy()
        plainButton.configureWithDefault(for: .plain)
        self.buttonAppearance = plainButton
        
        let doneButton = buttonAppearance.copy()
        plainButton.configureWithDefault(for: .done)
        doneButtonAppearance = doneButton
        
        return self
    }
}
