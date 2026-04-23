//
//  AccountInfo.swift
//  LibraryBasics
//
//  Created by Janlor on 4/22/26.
//

import Foundation

/// 账户模型
public protocol AccountInfo {
    /// 访问令牌
    var accessToken: String? { get }
    /// 刷新令牌
    var refreshToken: String? { get }
}

public struct AccountInfoMO: AccountInfo, Codable {
    /// 访问令牌
    public var accessToken: String?
    /// 刷新令牌
    public var refreshToken: String?
}
