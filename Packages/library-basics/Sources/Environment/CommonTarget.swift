//
//  CommonTarget.swift
//  AppCommonTarget
//
//  Created by Janlor on 4/22/26.
//

import Foundation

public class CommonTarget: NSObject {
    /// info.plist
    private static var info: [String: Any] {
        Bundle.main.infoDictionary ?? [:]
    }
    
    /// 自定义的dictionary
    /// 在info.plist中key是 CustomUserDefine
    private static var customUserDefine: [String: Any] {
        let value = info["CustomUserDefine"]
        if case let dictionary as [String: Any] = value {
            return dictionary
        }
        return [:]
    }
}

public extension CommonTarget {
    struct TargetType: RawRepresentable, Codable, Hashable, Equatable {
        public let rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        /// AI数据分析助手
        public static let ai = TargetType(rawValue: "AIDataInsight")
    }
    
    /// 获取当前环境配置
    static var target: TargetType {
        // 使用 Info.plist 中的配置
        if let value = customUserDefine["target"] as? String {
            return TargetType(rawValue: value)
        }
        return .ai
    }
}
