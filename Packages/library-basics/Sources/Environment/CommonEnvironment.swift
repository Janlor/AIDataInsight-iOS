//
//  CommonEnvironment.swift
//  CommonEnvironment
//
//  Created by Janlor on 2024/5/22.
//

import Foundation
import UIKit
import BaseEnv

@objc(CommonEnvironment)
public class Environment: NSObject {
    
    @objc
    /// 授权相关配置
    public static let oauth: OAuth = OAuth()
    
    @objc
    /// 服务器相关配置
    public static let server: Server = Server()
    
    @objc
    /// 安装渠道
    public static let channel: Channel = Channel()
    
    @objc
    /// 网页相关配置
    public static let web: Web = Web()
}

@objc(AppOAuth)
/// 授权相关配置
public class OAuth: NSObject {
    
    @objc
    public var appid: String {
        switch EnvInfo.env {
        case .appStore, .pre:
            return ""
        default:
            return ""
        }
    }
    
    @objc
    public var appSecret: String {
        switch EnvInfo.env {
        case .appStore, .pre:
            return ""
        default:
            return ""
        }
    }
    
    @objc
    public var appSalt: String {
        switch EnvInfo.env {
        case .appStore, .pre:
            return ""
        default:
            return ""
        }
    }
    
    @objc
    public var authURL: URL? {
        switch EnvInfo.env {
        case .unknow:
            return nil
        case .appStore:
            return URL(string: "")
        case .pre:
            return URL(string: "")
        case .staging:
            return URL(string: "")
        case .uat:
            return URL(string: "")
        case .sit:
            return URL(string: "")
        case .dev:
            return URL(string: "")
        }
    }
}

@objc(AppServer)
/// 服务器相关配置
public class Server: NSObject {
    
    @objc
    public var baseURL: URL {
        let mockURLString = "https://m1.apifoxmock.com/m1/3174267-1700689-default"
        
        switch EnvInfo.env {
        case .pre:
            switch CommonTarget.target {
            default:
                return URL(string: mockURLString)! // 准生产
            }
        case .staging:
            return URL(string: mockURLString)! // 预发布
        case .uat:
            return URL(string: mockURLString)! // 测试
        case .sit:
            return URL(string: mockURLString)! // 测试
        case .dev:
            return URL(string: mockURLString)!
        default: // 默认生产环境
            switch CommonTarget.target {
            default:
                return URL(string: mockURLString)! // 生产
            }
        }
    }
    
    @objc
    public var uploadURL: URL {
        switch EnvInfo.env {
        case .pre:
            return URL(string: "")!
        case .uat:
            return URL(string: "")!
        case .sit:
            return URL(string: "")!
        case .dev:
            return URL(string: "")!
        default: // 默认生产环境
            return URL(string: "")!
        }
    }
    
    @objc
    public var updatePath: String {
        switch CommonTarget.target {
        default:
            return "/download/iOSAppVersionConfigure.json"
        }
    }
    
    @objc
    public var privacyPolicyURL: String {
        switch CommonTarget.target {
        default:
            return "https://example.com.cn/privacypolicy"
        }
    }
}

@objc(AppWeb)
/// 网页相关配置
public class Web: NSObject {
    
    @objc
    public var host: String {
        switch CommonTarget.target {
        default:
            return hbHost
        }
    }
    
    public var hbHost: String {
        switch EnvInfo.env {
        case .unknow:
            return ""
        case .appStore:
            return ""
        case .pre:
            return ""
        case .staging:
            return ""
        case .uat:
            return ""
        case .sit:
            return ""
        case .dev:
            return ""
        }
    }
}

@objc(AppChannel)
/// 安装渠道
public class Channel: NSObject {
    public var inferredChannel: String {
        let env = Bundle.main.inferredEnvironment
        switch env {
        case .debug:
            return "Debug"
        case .testFlight:
            return "TestFlight"
        case .appStore:
            return "App Store"
        }
    }
}
