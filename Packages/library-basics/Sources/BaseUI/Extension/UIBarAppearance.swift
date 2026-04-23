//
//  UIBarAppearance.swift
//  LibraryCommon
//
//  Created by Janlor on 4/22/26.
//

import Foundation
import UIKit

@available(iOS 13.0, *)
public extension UIBarAppearance {

    @discardableResult
    // 正常情况下的样式
    @objc func normal(backgroundColor: UIColor = .white, background image: UIImage? = nil) -> Self {
        self.backgroundColor = backgroundColor
        backgroundImage = image
        backgroundEffect = nil
//        shadowImage = .clear
        shadowColor = .clear
        return self
    }

    @discardableResult
    /// 透明样式
    @objc func transparency() -> Self {
        configureWithTransparentBackground()
        return self
    }
}
