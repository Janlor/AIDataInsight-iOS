//
//  CommonTarget.swift
//  AppCommonTarget
//
//  Created by Janlor on 2024/12/19.
//

import Foundation
import BaseEnv

public class CommonTarget: NSObject {
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
        let customUserDefine = AppRuntimeSettings.customUserDefine()
        if let value = customUserDefine["target"] as? String {
            return TargetType(rawValue: value)
        }
        return .ai
    }
}
