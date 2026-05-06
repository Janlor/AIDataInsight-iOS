//
//  OAuthModel.swift
//  LibraryCommon
//
//  Created by Janlor on 2024/5/29.
//

import Foundation
import AccountProtocol

struct OAuthModel: Codable, AccountInfo {
    /// 访问令牌
    var accessToken: String?
    /// 刷新令牌
    var refreshToken: String?
    /// 令牌有效期
    var expiresIn: Int?
    /// 刷新令牌有效期
    var refreshExpiresIn: Int?
    /// 客户端id
    var clientId: String?
    /// 权限范围
    var scope: String?
    /// 开放id
    var openid: String?
}
