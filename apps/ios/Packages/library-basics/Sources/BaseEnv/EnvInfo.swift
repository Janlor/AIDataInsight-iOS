//
//  EnvInfo.swift
//  AppEnvInfo
//
//  Created by Janlor on 2024/5/22.
//

import Foundation

@objc(AppEnvInfo)
public class EnvInfo: NSObject {
}

public extension EnvInfo {
    
    @objc enum EnvType: Int, CustomStringConvertible, CaseIterable {
        case unknow   = 0 //
        case appStore = 1 // 生产环境
        case pre      = 2 // 准生产环境
        case staging  = 3 // 预发布环境
        case uat      = 4 // 验收环境
        case sit      = 5 // 综合测试环境
        case dev      = 6 // 开发环境
        
        public var description: String {
            switch self {
            case .appStore:
                return "生产环境"
            case .pre:
                return "准生产环境"
            case .staging:
                return "预发布环境"
            case .uat:
                return "用户验收测试环境"
            case .sit:
                return "系统集成测试环境"
            case .dev:
                return "开发环境"
            default:
                return "未知环境"
            }
        }
    }
    
    /// 获取当前环境配置
    @objc static var env: EnvType {
        // 使用 Info.plist 中的配置
        let customUserDefine = AppRuntimeSettings.customUserDefine()
        guard let envValue = customUserDefine["env"] as? String,
              let rawValue = Int(envValue),
              let env = EnvType(rawValue: rawValue) else {
            return .appStore
        }
        
        // 如果是生产环境、准生产环境，忽略用户自定义的环境
        if env == .appStore || env == .pre {
            UserDefaults.standard.removeObject(forKey: "CustomEnv") // 清除残留配置
            return env
        }
        
        // 检查 UserDefaults 中是否有保存的环境配置
        if let savedEnv = UserDefaults.standard.value(forKey: AppRuntimeSettings.customEnvKey) as? Int,
           let validEnv = EnvType(rawValue: savedEnv), validEnv != .unknow {
            return validEnv
        }
        
        // 返回 plist 中定义的环境
        return env
    }
    
    /// 切换环境并保存到 UserDefaults
    static func switchEnv(to env: EnvType) {
        UserDefaults.standard.set(env.rawValue, forKey: AppRuntimeSettings.customEnvKey)
        UserDefaults.standard.synchronize()
    }
}
