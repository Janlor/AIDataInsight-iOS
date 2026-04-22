//
//  KeychainKeyManager.swift
//  LibraryBasics
//
//  Created by Janlor on 2025/12/30.
//

import Security
import Foundation

final class KeychainKeyManager {

    static let shared = KeychainKeyManager()
    private init() {}

    /// 单独命名，避免和 token / account 混
    private let keyName = "cache_aes_key"

    /// 获取或生成 AES Key（AES-256）
    func loadOrCreateKey() throws -> Data {

        // 1. 尝试读取
        if let key = KeychainStore.shared.loadData(
            for: keyName,
            sync: .deviceOnly   // ⚠️ 非 iCloud，同设备绑定
        ) {
            return key
        }

        // 2. 生成新 Key
        let newKey = generateKey()

        // 3. 保存
        let success = KeychainStore.shared.saveData(
            newKey,
            for: keyName,
            sync: .deviceOnly,
            accessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        )

        guard success else {
            throw NSError(domain: "KeychainKeyManager", code: -1)
        }

        return newKey
    }

    /// 生成 32 bytes 随机 AES Key
    private func generateKey() -> Data {
        var data = Data(count: 32)
        _ = data.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, 32, $0.baseAddress!)
        }
        return data
    }
}
