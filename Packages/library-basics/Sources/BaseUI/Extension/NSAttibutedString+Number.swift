//
//  NSAttibutedString+Number.swift
//  LibraryCommon
//
//  Created by Janlor on 4/22/26.
//

import UIKit

public extension NSAttributedString {
    static func highlightedAttributedString(
        string: String,
        highlight: String,
        defaultColor: UIColor = .theme.secondaryLabel,
        highlightColor: UIColor = .theme.accent,
        defaultFont: UIFont = .theme.caption1,
        highlightFont: UIFont? = nil
    ) -> NSAttributedString {
        // 定义默认属性
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: defaultColor,
            .font: defaultFont
        ]
        
        // 创建可变富文本字符串
        let attributedString = NSMutableAttributedString(string: string, attributes: attributes)
        
        // 找到数字的位置并应用高亮属性
        if let range = string.range(of: highlight) {
            let nsRange = NSRange(range, in: string)
            
            var highlightAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: highlightColor
            ]
            
            // 如果提供了高亮字体，则添加字体属性
            if let highlightFont = highlightFont {
                highlightAttributes[.font] = highlightFont
            }
            
            attributedString.addAttributes(highlightAttributes, range: nsRange)
        }
        
        return attributedString
    }
}
