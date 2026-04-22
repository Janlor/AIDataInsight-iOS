//
//  RealmCleanupHelper.swift
//  LibraryBasics
//
//  Created by Janlor on 2025/12/9.
//

import Foundation

enum RealmCleanupHelper {
    /// 检查并删除旧 Realm 文件（仅首次执行）
    static func cleanUpIfNeeded() {
        let userDefaultsKey = "hasCleanedRealmFiles"
        let defaults = UserDefaults.standard
        
        // 已执行过则跳过
        guard defaults.bool(forKey: userDefaultsKey) == false else { return }
        
        let fileManager = FileManager.default
        guard let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("⚠️ 无法获取 Documents 目录。")
            return
        }

        // Realm 默认文件名
        let realmBaseName = "default.realm"
        let realmBaseURL = documents.appendingPathComponent(realmBaseName)
        let realmBasePath = realmBaseURL.deletingPathExtension().path
        
        // 所有可能的 Realm 相关文件/目录
        let relatedPaths = [
            realmBasePath + ".realm",
            realmBasePath + ".realm.lock",
            realmBasePath + ".realm.note",
            realmBasePath + ".realm.management" // 注意：这个是目录
        ]
        
        var deletedCount = 0
        
        for path in relatedPaths {
            if fileManager.fileExists(atPath: path) {
                do {
                    try fileManager.removeItem(atPath: path)
                    deletedCount += 1
                } catch {
                    print("⚠️ 删除 \(path) 失败：\(error)")
                }
            }
        }
        
        if deletedCount > 0 {
            print("🧹 已清理旧 Realm 文件 (\(deletedCount) 项)。")
        } else {
            print("✅ 未发现 Realm 文件，无需清理。")
        }

        // 标记已清理，防止重复执行
        defaults.set(true, forKey: userDefaultsKey)
    }
}
