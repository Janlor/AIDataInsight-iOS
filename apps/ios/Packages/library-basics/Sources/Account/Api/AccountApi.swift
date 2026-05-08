//
//  AccountApi.swift
//  LibraryCommon
//
//  Created by Janlor on 2024/5/29.
//

import Foundation
import Networking

enum AccountApi: RequestDescriptor {
    /// 查询用户信息
    case getUserInfo
    
    /// 修改密码
    /// oldPwd 旧密码
    /// newPwd 新密码
    case updatePwd(String, String)
    
    /// 查询菜单权限
    case menuTree
    
    var path: String {
        switch self {
        case .getUserInfo:
            return "/oauth2/getUserInfo"
        case .updatePwd:
            return "/oauth2/updatePwd"
        case .menuTree:
            return "/oauth2/menuTree"
        }
    }
    
    var method: Networking.Method {
        switch self {
        case .updatePwd(_, _):
            return .post
        case .getUserInfo, .menuTree:
            return .get
        }
    }
    
    var parameters: [String : Any] {
        switch self {
        case .getUserInfo:
            return [:]
        case let .updatePwd(oldPwd, newPwd):
            return [
                "oldPwd": oldPwd,
                "newPwd": newPwd
            ]
        case .menuTree:
            return [:]
        }
    }
}
