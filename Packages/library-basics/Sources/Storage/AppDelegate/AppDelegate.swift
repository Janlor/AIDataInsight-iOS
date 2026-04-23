//
//  AppDelegate.swift
//  Account
//
//  Created by Janlor on 4/22/26.
//

import UIKit
import AppLaunch
//import RealmSwift

/// 组件名称
let mircoAppModuleName = "Storage"

class AppDelegate: UIResponder, AppDelegateModule {

    var moduleName: String { mircoAppModuleName }
    
    var tokens: [NSObjectProtocol] = []
        
    var window: UIWindow?
    
    func load(_ window: UIWindow?) {
        self.window = window
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//        setRealm()
        RealmCleanupHelper.cleanUpIfNeeded()
        return true
    }
    
//    func setRealm() {
//        let config = Realm.Configuration(
//            // 设置新的架构版本。这个版本号必须高于之前所用的版本号（如果您之前从未设置过架构版本，那么这个版本号设置为 0）
//            schemaVersion: 0,
//            // 设置闭包，这个闭包将会在打开低于上面所设置版本号的 Realm 数据库的时候被自动调用
//            migrationBlock: { migration, oldSchemaVersion in
//                // 目前我们还未进行数据迁移，因此 oldSchemaVersion == 0
//                if oldSchemaVersion < 1 {
//                    // 什么都不要做！Realm 会自行检测新增和需要移除的属性，然后自动更新硬盘上的数据库架构
//                }
//            }
//        )
//        // 告诉 Realm 为默认的 Realm 数据库使用这个新的配置对象
//        Realm.Configuration.defaultConfiguration = config
//        // 现在我们已经告诉了 Realm 如何处理架构的变化，打开文件之后将会自动执行迁移
//        do {
//            _ = try Realm()
//        } catch let error {
//            print("Failed to open Realm: \(error.localizedDescription)")
//        }
//    }
}

private extension AppForwarder {
    @objc dynamic func app_entry_Storage() {
        entry {
            AppDelegate()
        }
    }
}
