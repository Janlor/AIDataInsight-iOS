//
//  KeychainStore.swift
//  LibraryBasics
//
//  Created by Janlor on 2025/12/30.
//

import Foundation
import Security

public enum KeychainSyncPolicy {
    case deviceOnly          // 不同步（缓存 / 本地状态）
    case iCloud              // iCloud 同步（登录态 / token）
}

public final class KeychainStore {

    public static let shared = KeychainStore()

    private let service: String

    private init() {
        self.service = Bundle.main.bundleIdentifier! + ".secure"
    }

    // MARK: - Save / Update

    @discardableResult
    public func save<T: Codable>(
        _ value: T,
        for key: String,
        sync: KeychainSyncPolicy = .deviceOnly,
        accessible: CFString = kSecAttrAccessibleAfterFirstUnlock
    ) -> Bool {
        do {
            let data = try JSONEncoder().encode(value)
            return saveData(data, for: key, sync: sync, accessible: accessible)
        } catch {
            return false
        }
    }

    @discardableResult
    public func saveData(
        _ data: Data,
        for key: String,
        sync: KeychainSyncPolicy,
        accessible: CFString = kSecAttrAccessibleAfterFirstUnlock
    ) -> Bool {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key,
            kSecAttrAccessible: accessible,
            kSecAttrSynchronizable: sync == .iCloud,
            kSecValueData: data
        ]

        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    // MARK: - Load

    public func load<T: Codable>(
        _ type: T.Type,
        for key: String,
        sync: KeychainSyncPolicy = .deviceOnly
    ) -> T? {
        guard let data = loadData(for: key, sync: sync) else {
            return nil
        }
        return try? JSONDecoder().decode(type, from: data)
    }

    public func loadData(
        for key: String,
        sync: KeychainSyncPolicy
    ) -> Data? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key,
            kSecAttrSynchronizable: sync == .iCloud,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        return status == errSecSuccess ? result as? Data : nil
    }

    // MARK: - Remove

    public func remove(
        for key: String,
        sync: KeychainSyncPolicy = .deviceOnly
    ) {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key,
            kSecAttrSynchronizable: sync == .iCloud
        ]
        SecItemDelete(query as CFDictionary)
    }

    public func removeAll() {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service
        ]
        SecItemDelete(query as CFDictionary)
    }
}
