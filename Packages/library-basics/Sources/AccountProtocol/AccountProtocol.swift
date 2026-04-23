//
//  AccountProtocol.swift
//  LibraryBasics
//
//  Created by Janlor on 4/22/26.
//

import Foundation
import UIKit

public extension Notification.Name {
    static let accountDidUpdate = Notification.Name("Account.AccountDidUpdateNotification")
    static let userDidUpdate = Notification.Name("Account.UserDidUpdateNotification")
    static let userOrgListDidUpdate = Notification.Name("Account.UserOrgListDidUpdateNotification")
    static let subSysListDidUpdate = Notification.Name("Account.SubSysListDidUpdateNotification")
    static let menuListDidUpdate = Notification.Name("Account.MenuListDidUpdateNotification")
}

public extension Notification.Name {
    /// 鉴权成功（token 已就绪）
    static let authSucceed = Notification.Name("Auth.auth.succeed")
    
    /// 鉴权失败
    static let authFailed = Notification.Name("Auth.auth.failed")
    
    /// 会话已就绪（可以进入首页）
    static let sessionReady = Notification.Name("Account.session.ready")
    
    /// 退出登录成功通知
    static let logoutSucceed = Notification.Name("Account.logout.success")
}

public protocol AccountProtocol {
       
    // MARK: 以下是指定的基础方法
    
    /// 更新账户
    @discardableResult
    func update<T>(account info: T) -> Bool where T: AccountInfo, T: Codable
    
    /// 更新用户信息
    @discardableResult
    func updateUser<T>(_ info: T) -> Bool where T: UserInfo, T: Codable
    
    /// 更新用户所属机构列表
    @discardableResult
    func updateUserOrgList<T>(_ info: [T]) -> Bool where T : UserOrgProtocal, T : Codable
    
    /// 保存用户所属机构
    @discardableResult
    func update<T>(userOrg info: T) -> Bool where T : UserOrgProtocal, T : Codable
    
    /// 保存菜单
    @discardableResult
    func update<T>(menus info: [T]) -> Bool where T : MenuProtocol, T : Codable
    
    /// 移出账户
    func remove()
    
    /// 查询账户。未登录的情况下返回nil
    func `get`<T>(_ type: T.Type) -> T? where T: AccountInfo, T: Codable
    
    /// 查询用户。未登录的情况下返回nil
    func getUser<T>(_ type: T.Type) -> T? where T: UserInfo, T: Codable
    
    /// 查询用户所属机构列表。未登录的情况下返回nil
    func fetchUserOrgList<T: UserOrgProtocal & Codable>(_ type: T.Type) -> [T]?

    /// 获取用户所属机构
    func fetch<T: UserOrgProtocal & Codable>(userOrg type: T.Type) -> T?
    
    /// 获取菜单
    func fetch<T>(menu type: T.Type) -> [T]? where T : MenuProtocol, T : Codable
    
    // MARK: 以下是便利方法
    
    /// true：已登录，false ：未登录
    var isLogin: Bool { get }
    
    /// 访问令牌
    var accessToken: String? { get }
    
    /// 刷新令牌
    var refreshToken: String? { get }
    
    /// 当前组织ID
    var orgId: Int? { get }
    
    /// 用户唯一标识
    var username: String? { get }
    
    // MARK: - Network
    
    /// 获取用户信息
    func getUserInfo<T>(_ reslut: @escaping (T?, String?) -> Void) where T: UserInfo, T: Codable
    
    /// 获取菜单
    func getMenuTree<T>(_ reslut: @escaping ([T]?, String?) -> Void) where T: MenuProtocol, T: Codable
    
    // MARK: - Event
    
    /// 打开修改密码页面
    func toUpdatePassword(from: UIViewController)
}
