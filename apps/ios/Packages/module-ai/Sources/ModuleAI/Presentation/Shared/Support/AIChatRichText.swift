//
//  AIChatRichText.swift
//  ModuleAI
//
//  Created by Janlor on 2024/10/24.
//

import UIKit

struct AIChatRichText {
    let text: String
    var attributes: [NSAttributedString.Key: Any]
    
    init(text: String, attributes: [NSAttributedString.Key: Any] = [:]) {
        self.text = text
        self.attributes = attributes
        
        // 设置默认字体和颜色
        if self.attributes[.font] == nil {
            self.attributes[.font] = UIFont.theme.subhead
        }
        if self.attributes[.foregroundColor] == nil {
            self.attributes[.foregroundColor] = UIColor.theme.label
        }
    }
    
    var bold: AIChatRichText {
        var new = self
        new.attributes[.font] = UIFont.theme.title31
        return new
    }
    
    func link(_ url: String) -> AIChatRichText {
        var new = self
        new.attributes[.link] = url
        return new
    }
    
    var underline: AIChatRichText {
        var new = self
        new.attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue | NSUnderlineStyle.patternDashDot.rawValue
        new.attributes[.underlineColor] = UIColor.systemGray
        return new
    }
}

extension AIChatRichText {
    // 从 RichText 数组生成 NSAttributedString
    static func attributedString(from richTexts: [AIChatRichText]) -> NSAttributedString {
        let attributedString = NSMutableAttributedString()
        for richText in richTexts {
            let part = NSAttributedString(string: richText.text, attributes: richText.attributes)
            attributedString.append(part)
        }
        
        // 设置段落样式
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4 // 行距
        paragraphStyle.paragraphSpacing = 4 // 段落间距
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
        
        return attributedString
    }
}
