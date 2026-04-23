//
//  UserInfoModel.swift
//  LibraryCommon
//
//  Created by Janlor on 4/22/26.
//

import Foundation
import AccountProtocol

/// 用户信息模型
struct UserInfoModel: UserInfo, Codable {
    var id: Int?
    /// 手机号
    var phone: String?
    /// 登录名
    var username: String?
    /// 用户名称
    var nikeName: String?
}
