//
//  NetworkCacheable.swift
//  LibraryBasics
//
//  Created by Janlor on 4/22/26.
//

import Foundation

public protocol NetworkCacheable: Codable { }

public protocol NetworkCachePolicy {
    var cacheStrategy: NetworkCacheStrategy { get }
    var securityLevel: NetworkCacheSecurityLevel { get }
}

public extension NetworkCachePolicy {
    // 默认不开启缓存
    var cacheStrategy: NetworkCacheStrategy { .networkOnly }
    // 默认加密
    var securityLevel: NetworkCacheSecurityLevel { .encrypted }
}

public enum NetworkCacheStrategy: Equatable {
    case alwaysValid               // 报表 / 历史
    case expireAfter(TimeInterval) // 高时效
    case networkOnly               // 不缓存
    
    func shouldInvalidateCache(
        _ cacheTime: TimeInterval
    ) -> Bool {
        switch self {
        case .alwaysValid:
            return false
        case .expireAfter(let ttl):
            return Date().timeIntervalSince1970 - cacheTime > ttl
        case .networkOnly:
            return true
        }
    }
}

public enum NetworkCacheSecurityLevel {
    case normal      // 报表 / 列表
    case sensitive   // 不落盘
    case encrypted   // AES
}

public struct NetworkCacheWrapper<T: Codable>: Codable {
    public let value: T
    public let cacheTime: TimeInterval

    public init(value: T, cacheTime: TimeInterval = Date().timeIntervalSince1970) {
        self.value = value
        self.cacheTime = cacheTime
    }
}

/// 数据未加密保护
public enum NetworkCache {

    public static func save<T: Codable>(_ value: T, for key: String) {
        let wrapper = NetworkCacheWrapper(value: value)
        let url = cacheURL(for: key)

        do {
            let data = try JSONEncoder().encode(wrapper)
            try data.write(to: url)
        } catch {
            print("Cache save failed:", error)
        }
    }

    public static func load<T: Codable>(
        _ type: T.Type,
        for key: String
    ) -> NetworkCacheWrapper<T>? {
        let url = cacheURL(for: key)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(NetworkCacheWrapper<T>.self, from: data)
    }

    private static func cacheURL(for key: String) -> URL {
        let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return dir.appendingPathComponent(key)
    }
}
