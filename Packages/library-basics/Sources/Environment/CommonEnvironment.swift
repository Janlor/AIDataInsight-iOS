//
//  CommonEnvironment.swift
//  CommonEnvironment
//
//  Created by Janlor on 2024/5/22.
//

import Foundation
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
        AppEnvironmentValues.oauthAppId(env: EnvInfo.env)
    }
    
    @objc
    public var appSecret: String {
        AppEnvironmentValues.oauthAppSecret(env: EnvInfo.env)
    }
    
    @objc
    public var appSalt: String {
        AppEnvironmentValues.oauthAppSalt(env: EnvInfo.env)
    }
    
    @objc
    public var authURL: URL? {
        AppEnvironmentValues.authURL(env: EnvInfo.env)
    }
}

@objc(AppServer)
/// 服务器相关配置
public class Server: NSObject {
    @objc
    public var baseURL: URL {
        AppEnvironmentValues.baseURL(env: EnvInfo.env, target: CommonTarget.target)
    }
    
    @objc
    public var uploadURL: URL {
        AppEnvironmentValues.uploadURL(env: EnvInfo.env)
    }
    
    @objc
    public var updatePath: String {
        AppEnvironmentValues.updatePath(target: CommonTarget.target)
    }
    
    @objc
    public var privacyPolicyURL: String {
        AppEnvironmentValues.privacyPolicyURL(target: CommonTarget.target)
    }
}

@objc(AppWeb)
/// 网页相关配置
public class Web: NSObject {
    @objc
    public var host: String {
        AppEnvironmentValues.webHost(env: EnvInfo.env, target: CommonTarget.target)
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
