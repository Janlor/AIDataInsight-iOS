//
//  OAuthApi.swift
//  LibraryCommon
//
//  Created by Janlor on 2024/5/29.
//

import Foundation
import Networking

enum OAuthApi: RequestDescriptor {
    
    /// 账号登录
    /// name 账号
    /// pwd 密码
    case login(String, String)
    
    /// 刷新 Token
    /// refreshToken 刷新令牌
    case refresh(String)
    
    /// 退出登录
    case logout
    
    var path: String {
        switch self {
        case .login(_, _):
            return "/oauth2/login"
        case .refresh(_):
            return "/oauth2/refresh"
        case .logout:
            return "/oauth2/logout"
        }
    }
    
    var method: Networking.Method {
        switch self {
        case .login(_, _):
            return .post
        case .refresh(_), .logout:
            return .get
        }
    }
    
    var parameters: [String : Any] {
        switch self {
        case let .login(name, pwd):
            return [
                "name": name,
                "pwd": pwd
            ]
        case let .refresh(refreshToken):
            return [
                "refreshToken": refreshToken
            ]
        case .logout:
            return [:]
        }
    }
}
