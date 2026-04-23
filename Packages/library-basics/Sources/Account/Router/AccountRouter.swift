//
//  AccountRouter.swift
//  LibraryBasics
//
//  Created by Janlor on 4/22/26.
//

import UIKit
import Router
import AccountProtocol
import Storage
import Networking

class AccountRouter: RouterDestination {
    
    func to(_ arg: [AnyHashable : Any]?, _ closure: ((Any, [AnyHashable : Any]?) -> Void)?) -> UIViewController {
        UIViewController()
    }
    
    init() {
        NotificationCenter.default.addObserver(forName: .authSucceed, object: nil, queue: .main) { [weak self] _ in
            self?.prepareSession()
        }
    }
}

private let account_data_key = "Account.account_data_key"
private let user_data_key = "Account.user_data_key"
private let user_org_list_key = "Account.user_org_list_key"
private let user_org_key = "Account.user_org_key"
private let menu_list_key = "Account.menu_list_key"

private let accountEncoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase
    return encoder
}()

private let accountDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
}()

extension AccountRouter: AccountProtocol {
    static var account: AccountInfoMO?
    static var user: UserInfoMO?
    static var userOrgList: [UserOrgModel]?
    static var menuList: [MenuModel]?
    
    func update<T>(account info: T) -> Bool where T : AccountInfo, T : Codable {
        do {
            let data = try accountEncoder.encode(info)
            KeychainStore.shared.saveData(data, for: account_data_key, sync: .iCloud)
            Self.account = try? accountDecoder.decode(AccountInfoMO.self, from: data)
            NotificationCenter.default.post(name: .accountDidUpdate, object: Self.account)
            return true
        } catch {
            return false
        }
    }
    
    func updateUser<T>(_ info: T) -> Bool where T : UserInfo, T : Codable {
        do {
            let data = try accountEncoder.encode(info)
            KeychainStore.shared.saveData(data, for: user_data_key, sync: .iCloud)
            Self.user = try? accountDecoder.decode(UserInfoMO.self, from: data)
            NotificationCenter.default.post(name: .userDidUpdate, object: Self.user)
            return true
        } catch {
            return false
        }
    }
    
    func update<T>(menus info: [T]) -> Bool where T : MenuProtocol, T : Codable {
        do {
            let data = try accountEncoder.encode(info)
            KeychainStore.shared.saveData(data, for: menu_list_key, sync: .iCloud)
            Self.menuList = try? accountDecoder.decode([MenuModel].self, from: data)
            NotificationCenter.default.post(name: .menuListDidUpdate, object: Self.menuList)
            return true
        } catch {
            return false
        }
    }
    
    /// 更新用户所属机构列表
    func updateUserOrgList<T>(_ info: [T]) -> Bool where T : UserOrgProtocal, T : Codable {
        do {
            let data = try accountEncoder.encode(info)
            KeychainStore.shared.saveData(data, for: user_org_list_key, sync: .iCloud)
            Self.userOrgList = try? accountDecoder.decode([UserOrgModel].self, from: data)
            NotificationCenter.default.post(name: .userOrgListDidUpdate, object: Self.userOrgList)
            return true
        } catch {
            return false
        }
    }
    
    func update<T>(userOrg info: T) -> Bool where T : UserOrgProtocal, T : Codable {
        guard let userId = username else { return false }
        let key = "\(user_org_key)_\(userId)"
        
        migrateUserOrgDataIfNeed()
        
        do {
            let data = try accountEncoder.encode(info)
            KeychainStore.shared.saveData(data, for: key, sync: .iCloud)
            return true
        } catch {
            return false
        }
    }
    
    func remove() {
        if let userId = username {
            KeychainStore.shared.remove(for: "\(user_org_key)_\(userId)", sync: .iCloud)
        }
        
        KeychainStore.shared.remove(for: account_data_key, sync: .iCloud)
        KeychainStore.shared.remove(for: user_data_key, sync: .iCloud)
        KeychainStore.shared.remove(for: user_org_list_key, sync: .iCloud)
        KeychainStore.shared.remove(for: menu_list_key, sync: .iCloud)
        
        UserDefaults.standard.set(nil, forKey: account_data_key)
        UserDefaults.standard.set(nil, forKey: user_data_key)
        UserDefaults.standard.set(nil, forKey: user_org_list_key)
        UserDefaults.standard.set(nil, forKey: user_org_key)
        UserDefaults.standard.set(nil, forKey: menu_list_key)
        UserDefaults.standard.synchronize()
        
        Self.account = nil
        Self.user = nil
        Self.userOrgList = nil
    }
    
    func get<T>(_ type: T.Type) -> T? where T: AccountInfo, T: Codable {
        if type is AccountInfoMO.Type, let account = Self.account {
            return account as? T
        }
        
        // 迁移老数据
        migrateDataIfNeed(for: account_data_key)

        guard let data = KeychainStore.shared.loadData(for: account_data_key, sync: .iCloud) else {
            return nil
        }

        if type is AccountInfoMO.Type {
            Self.account = try? accountDecoder.decode(AccountInfoMO.self, from: data)
            return Self.account as? T
        }

        return try? accountDecoder.decode(type, from: data)
    }
    
    func getUser<T: UserInfo & Codable>(_ type: T.Type) -> T? {
        if type is UserInfoMO.Type, let user = Self.user as? T {
            return user
        }
        
        // 迁移老数据
        migrateDataIfNeed(for: user_data_key)

        guard let data = KeychainStore.shared.loadData(for: user_data_key, sync: .iCloud) else {
            return nil
        }
        
        if type is UserInfoMO.Type {
            Self.user = try? accountDecoder.decode(UserInfoMO.self, from: data)
            return Self.user as? T
        }
        
        return try? accountDecoder.decode(type, from: data)
    }
    
    /// 查询用户所属机构列表
    func fetchUserOrgList<T>(_ type: T.Type) -> [T]? where T: UserOrgProtocal & Codable {
        if type is [UserOrgModel].Type, let userOrgList = Self.userOrgList {
            return userOrgList as? [T]
        }
        
        // 迁移老数据
        migrateDataIfNeed(for: user_org_list_key)

        guard let data = KeychainStore.shared.loadData(for: user_org_list_key, sync: .iCloud) else {
            return nil
        }
        
        if type is [UserOrgModel].Type {
            Self.userOrgList = try? accountDecoder.decode([UserOrgModel].self, from: data)
            return Self.userOrgList as? [T]
        }
        
        return try? accountDecoder.decode([T].self, from: data)
    }
    
    func fetch<T>(userOrg type: T.Type) -> T? where T : UserOrgProtocal, T : Codable {
        guard let userId = username else { return nil }
        let key = "\(user_org_key)_\(userId)"
        
        // 迁移老数据
        migrateUserOrgDataIfNeed()

        guard let data = KeychainStore.shared.loadData(for: key, sync: .iCloud) else {
            return nil
        }
        
        return try? accountDecoder.decode(type, from: data)
    }
    
    func fetch<T>(menu type: T.Type) -> [T]? where T : MenuProtocol, T : Codable {
        if type is [MenuModel].Type, let menuList = Self.menuList {
            return menuList as? [T]
        }
        
        // 迁移老数据
        migrateDataIfNeed(for: menu_list_key)

        guard let data = KeychainStore.shared.loadData(for: menu_list_key, sync: .iCloud) else {
            return nil
        }
        
        if type is [MenuModel].Type {
            Self.menuList = try? accountDecoder.decode([MenuModel].self, from: data)
            return Self.menuList as? [T]
        }
        
        return try? accountDecoder.decode([T].self, from: data)
    }
    
    var isLogin: Bool {
        guard let _ = accessToken else {
            return false
        }
        return true
    }
    
    var accessToken: String? {
        self.get(AccountInfoMO.self)?.accessToken
    }
    
    var refreshToken: String? {
        self.get(AccountInfoMO.self)?.refreshToken
    }
    
    /// 当前组织ID
    var orgId: Int? {
        self.fetch(userOrg: UserOrgModel.self)?.id
    }
    
    /// 登录名
    var username: String? {
        self.getUser(UserInfoMO.self)?.username
    }
    
    // MARK: - Network
    
    private func prepareSession() {
        let group = DispatchGroup()
        var errors = StringSet()
        
        group.enter()
        getUserInfo { (m: UserInfoMO?, e: String?) in
            errors.insert(e)
            group.leave()
        }
        
//        group.enter()
//        getMenuTree { (m: [MenuModel]?, e: String?) in
//            errors.insert(e)
//            group.leave()
//        }
        
        group.notify(queue: .main) {
            if errors.isEmpty {
                NotificationCenter.default.post(name: .sessionReady, object: nil)
            } else {
                self.remove()
                NotificationCenter.default.post(name: .authFailed, object: errors.values)
            }
        }

    }
    
    /// 获取用户信息
    func getUserInfo<T>(_ reslut: @escaping (T?, String?) -> Void) where T: UserInfo, T: Codable {
        let target = AccountApi.getUserInfo
        ResponseModel<T>.requestable(target) {
            response, error in
            guard error == nil, let model = response?.data else {
                reslut(nil, error?.localizedDescription ?? NSLocalizedString("未知错误", bundle: .module, comment: ""))
                return
            }
            self.updateUser(model)
            reslut(model, nil)
        }
    }
    
    /// 获取菜单
    func getMenuTree<T>(_ reslut: @escaping ([T]?, String?) -> Void) where T: MenuProtocol, T: Codable {
        let target = AccountApi.menuTree
        ResponseModel<[T]>.requestable(target) {
            response, error in
            guard error == nil, let models = response?.data else {
                reslut(nil, error?.localizedDescription ?? NSLocalizedString("未知错误", bundle: .module, comment: ""))
                return
            }
            self.update(menus: models)
            reslut(models, nil)
        }
    }
    
    // MARK: - Event
    
    /// 打开修改密码页面
    func toUpdatePassword(from: UIViewController) {
        let vc = UpdatePasswordController()
        from.navigationController?.pushViewController(vc, animated: true)
    }
}

private extension AccountRouter {
    /// 迁移老数据
    func migrateDataIfNeed(for key: String) {
        guard let data = UserDefaults.standard.data(forKey: key) else { return }
        guard KeychainStore.shared.saveData(data, for: key, sync: .iCloud) == true else { return }
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    /// 迁移用户组织老数据
    func migrateUserOrgDataIfNeed() {
        guard let dicts = UserDefaults.standard.dictionary(forKey: user_org_key) as? [String: Data] else { return }
        
        let allSucceeded = dicts.allSatisfy { key, data in
            KeychainStore.shared.saveData(data, for: "\(user_org_key)_\(key)", sync: .iCloud)
        }

        if allSucceeded {
            UserDefaults.standard.removeObject(forKey: user_org_key)
        }
    }
}

struct StringSet {
    private(set) var values = Set<String>()

    mutating func insert(_ value: String?) {
        guard let value = value, !value.isEmpty else { return }
        values.insert(value)
    }

    var isEmpty: Bool {
        values.isEmpty
    }
}
