//
//  EncryptedCache.swift
//  LibraryBasics
//
//  Created by Janlor on 2025/12/30.
//

import Foundation

public struct CacheWrapper<T: Codable>: Codable {
    public let value: T
    public let cacheTime: TimeInterval

    public init(value: T, cacheTime: TimeInterval = Date().timeIntervalSince1970) {
        self.value = value
        self.cacheTime = cacheTime
    }
}

/// 数据 AES 加密后二进制 + Keychain 存 Key
public enum EncryptedCache {

    private static let fileManager = FileManager.default

    public static func save<T: Codable>(_ value: T, for key: String) {
        do {
            let wrapper = CacheWrapper(value: value)
            let url = cacheURL(for: key)
            let json = try JSONEncoder().encode(wrapper)
            let aesKey = try KeychainKeyManager.shared.loadOrCreateKey()
            let encrypted = try CryptoHelper.encrypt(json, keyData: aesKey)
            // 系统级 AES 文件加密（设备锁屏❌未解锁重启❌用户解锁后✅）
            try encrypted.write(
                to: url,
                options: [.atomic, .completeFileProtection]
            )
        } catch {
            print("EncryptedCache save failed:", error)
        }
    }

    public static func load<T: Codable>(_ type: T.Type, for key: String) -> CacheWrapper<T>? {
        do {
            let url = cacheURL(for: key)
            let encrypted = try Data(contentsOf: url)
            let aesKey = try KeychainKeyManager.shared.loadOrCreateKey()
            let decrypted = try CryptoHelper.decrypt(encrypted, keyData: aesKey)
            return try JSONDecoder().decode(CacheWrapper<T>.self, from: decrypted)
        } catch {
            return nil
        }
    }

    private static func cacheURL(for key: String) -> URL {
        let dir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return dir.appendingPathComponent(key)
    }
}
