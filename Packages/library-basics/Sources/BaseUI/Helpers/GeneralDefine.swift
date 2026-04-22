//
//  GeneralDefine.swift
//  LibraryCommon
//
//  Created by Janlor on 5/30/24.
//

import Foundation

public func appLog(_ message: @autoclosure () -> Any, file: String = #file, function: String = #function, line: Int = #line) {
    #if DEBUG
    print("[\(file):\(line)] \(function) - \(message())")
    #endif
}

// 最大的 iPhone 宽度
public let maxPhoneWidth: CGFloat = 440.0
