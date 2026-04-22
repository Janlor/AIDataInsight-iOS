//
//  TouchableScrollView.swift
//  LibraryBasics
//
//  Created by Janlor on 2025/11/4.
//

import UIKit

/// 提供统一的行为封装
protocol ScrollViewTouchableCancellable: AnyObject {
    func setupGestureBehavior()
}

extension ScrollViewTouchableCancellable where Self: UIScrollView {
    func setupGestureBehavior() {
        canCancelContentTouches = true
        delaysContentTouches = false
    }
}

/// 提供默认实现的基类，可直接继承使用
open class TouchableScrollView: UIScrollView, ScrollViewTouchableCancellable {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    open override func touchesShouldCancel(in view: UIView) -> Bool {
        if view is UIControl {
            return true
        }
        return super.touchesShouldCancel(in: view)
    }
    
    open func commonInit() {
        setupGestureBehavior()
    }
}
