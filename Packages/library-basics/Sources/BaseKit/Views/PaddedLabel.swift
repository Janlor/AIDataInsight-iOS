//
//  PaddedLabel.swift
//  LibraryBasics
//
//  Created by Janlor on 6/13/24.
//

import UIKit

/// 拥有布局边界的 Label
public class PaddedLabel: UILabel {
    public var contentInsets: UIEdgeInsets = .zero
    
    override public var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + contentInsets.left + contentInsets.right,
                      height: size.height + contentInsets.top + contentInsets.bottom)
    }
    
    override public func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: contentInsets))
    }
}

