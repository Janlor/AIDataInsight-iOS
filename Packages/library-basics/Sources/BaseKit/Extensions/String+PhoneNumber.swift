//
//  StringExtensions.swift
//  LibraryBasics
//
//  Created by Janlor on 4/22/26.
//

import Foundation

public extension String {
    /// 过滤出通讯录复制粘贴的手机号，移除国际区号和非数字字符
    /// - Returns: 去掉区号和特殊字符的纯数字手机号或座机号
    func trimmedTelePhoneNumber() -> String {
        // 匹配 + 开头，后面跟1到3位数字的国际区号
        let pattern = "^\\+\\d{1,3}"
        
        // 使用 try? 以防止正则表达式创建失败
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            // 如果正则表达式创建失败，直接返回当前字符串的数字部分
            return self.filter { "0123456789".contains($0) }
        }
        
        // 移除国际区号部分
        let range = NSRange(location: 0, length: self.utf16.count)
        let processedString = regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "")
        
        // 过滤掉非数字字符
        let filteredString = processedString.filter { "0123456789".contains($0) }
        
        return filteredString
    }
}
