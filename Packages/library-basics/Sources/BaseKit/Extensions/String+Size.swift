//
//  String+Size.swift
//  LibraryCommon
//
//  Created by Janlor on 4/22/26.
//

import UIKit

public extension String {
    /// 计算文本尺寸
    /// - Parameters:
    ///   - font: 字体
    ///   - maxSize: 最大尺寸
    /// - Returns: 计算的尺寸
    func textSize(font: UIFont, maxSize: CGSize) -> CGSize {
        // 创建一个包含字符串属性的字典
        let attributes = [NSAttributedString.Key.font: font]
        
        // 将字符串转换为 NSString，以便使用 boundingRect 方法
        let nsString = self as NSString
        
        // 计算字符串的尺寸
        let boundingRect = nsString.boundingRect(
            with: maxSize,
            options: .usesLineFragmentOrigin,
            attributes: attributes,
            context: nil
        )
        
        // 返回计算后的尺寸，并使用 ceil 函数确保尺寸是整数
        return CGSize(width: ceil(boundingRect.width), height: ceil(boundingRect.height))
    }
}
