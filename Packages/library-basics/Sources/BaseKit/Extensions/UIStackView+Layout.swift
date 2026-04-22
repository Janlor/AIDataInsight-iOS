//
//  UIStackView+Layout.swift
//  LibraryBasics
//
//  Created by Janlor on 2023/4/24.
//

import UIKit

public extension UIStackView {
    /// 添加背景色
    @discardableResult
    func addBackground(_ color: UIColor) -> UIView {
        let subview = UIView(frame: bounds)
        subview.backgroundColor = color
        subview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subview, at: 0)
        return subview
    }
    
    /// 设置布局边界
    func setLayoutMargin(_ margins: UIEdgeInsets) {
        layoutMargins = margins
        isLayoutMarginsRelativeArrangement = true
    }
}
