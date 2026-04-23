//
//  UITabBarItemExtensions.swift
//  LibraryCommon
//
//  Created by Janlor on 4/22/26.
//

import UIKit

public extension UITabBarItem {
    
    func normal() {
        setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.theme.tertieryLabel,
            NSAttributedString.Key.font: UIFont.theme.caption2
        ], for: .normal)
        setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor:  UIColor.theme.accent,
            NSAttributedString.Key.font: UIFont.theme.caption2
        ], for: .selected)
    }

    func transparency() {
        setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.theme.tertieryLabel,
            NSAttributedString.Key.font: UIFont.theme.caption2
        ], for: .normal)
        setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor:  UIColor.theme.accent,
            NSAttributedString.Key.font: UIFont.theme.caption2
        ], for: .selected)
    }
}

@available(iOS 13.0, *)
public extension UITabBarItemStateAppearance {
    
    func normal() {
        titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.theme.tertieryLabel,
//            NSAttributedString.Key.font: UIFont.theme.caption2
        ]
    }
    
    func selected() {
        titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.theme.accent,
//            NSAttributedString.Key.font: UIFont.theme.caption2
        ]
    }
}
