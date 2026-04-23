//
//  String+Extension.swift
//  ModuleAI
//
//  Created by Janlor on 4/22/26.
//

import Foundation

extension String {
    /// 判断是否以标点符号结尾
    func isLastCharacterPunctuation() -> Bool {
        // 确保字符串非空
        guard let lastCharacter = self.last else {
            return false
        }
        
        // 检查最后一个字符是否属于标点符号字符集
        let punctuationCharacterSet = CharacterSet.punctuationCharacters
        return punctuationCharacterSet.contains(lastCharacter.unicodeScalars.first!)
    }
}
