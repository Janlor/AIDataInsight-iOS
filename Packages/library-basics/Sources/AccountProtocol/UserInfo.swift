//
//  UserInfo.swift
//  LibraryBasics
//
//  Created by Janlor on 2026/1/12.
//

import Foundation

/// 用户个人信息
public protocol UserInfo {
    /// 机构id
//    var orgId: String? { get }
    /// 机构系统编码
//    var orgNo: String? { get set }
    /// 手机号
    var phone: String? { get set }
    /// 机构名称
//    var orgName: String? { get set }
//    var updateTime: String? { get set }
//    var updateAdmin: String? { get set }
    /// 子应用id
//    var subSysId: String? { get set }
    /// 业务权限
//    var dataPermission: String? { get set }
//    var selectPerm: String? { get set }
//    var createAdmin: String? { get set }
    /// 公司名称
//    var companyName: String? { get set }
    /// 登录名
    var username: String? { get set }
//    var userPassValidate: String? { get set }
//    var createTime: String? { get set }
    /// 菜单权限列表
//    var authList: [String]? { get set }
    /// 用户名称
    var nikeName: String? { get set }
//    var lockDate: String? { get set }
//    var loginNum: Int? { get set }
    var id: Int? { get set }
//    var permBitmap: String? { get set }
    /// 群组用户ids
//    var groupUserIds: [Int]? { get set }
//    var email: String? { get set }
    /// 公司id
//    var companyId: Int? { get set }
    /// 当前系统所有需要控制的url
//    var allAuthList: [String]? { get set }
//    var initPwd: String? { get set }
//    var userStatus: String? { get set }
}

/// 用户信息模型
public struct UserInfoMO: UserInfo, Codable {
    public var id: Int?
    /// 手机号
    public var phone: String?
    /// 登录名
    public var username: String?
    /// 用户名称
    public var nikeName: String?
}
