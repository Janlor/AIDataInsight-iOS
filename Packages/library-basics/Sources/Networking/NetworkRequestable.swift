//
//  NetworkRequestable.swift
//  LibraryBasics
//
//  Created by Janlor on 5/30/24.
//

import Foundation
import Storage

public protocol NetworkRequestable: Codable {
    
    /// 发起单个模型请求
    /// - Parameters:
    ///   - target: 接口信息
    ///   - completion: 回调
    @discardableResult
    static func requestable(
        _ target: CustomTargetType,
        completion: @escaping (Self?, NetworkError?) -> Void
    ) -> Cancellable
    
}

public extension NetworkRequestable {
    
    /// 发起单个模型请求
    /// - Parameters:
    ///   - target: 接口信息
    ///   - completion: 回调
    @discardableResult
    static func requestable(_ target: CustomTargetType,
                            completion: @escaping (Self?, NetworkError?) -> Void) -> Cancellable {
        return Network.requet(target) { data in
//            do {
//                let object = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
//                appLog(object)
//            } catch {
//
//            }
            do {
                let model = try NetworkDecoder.decode(Self.self, from: data)
                completion(model, nil)
            } catch {
//                print("Failed to decode JSON: \(error)")
                completion(nil, nil)
            }
        } error: { error in
            completion(nil, error)
        } failure: { error in
            completion(nil, error)
        }
    }
    
}

public enum DataState<T> {
    /// 来自缓存（可能过期）
    case cache(T)

    /// 来自网络（最新）
    case fresh(T)

    /// 明确无数据（例如 200 + 空数组）
    case empty

    /// 请求失败
    case error(NetworkError)
}

public extension NetworkRequestable where Self: NetworkCacheable {

    /// 发起单个请求（支持缓存策略）
    /// - Parameters:
    ///   - target: 接口信息
    ///   - completion: 回调带状态的数据
    /// - Returns: 可取消
    @discardableResult
    static func requestableWithState(
        _ target: CustomTargetType,
        loadCache: Bool = false,
        completion: @escaping (DataState<Self>) -> Void
    ) -> Cancellable {

        let key = target.cacheKey
        let policy = target as? NetworkCachePolicy

        // 先读缓存
        if loadCache, let cache = loadCacheData(target) {
            completion(cache)
        }

        // 请求网络
        return requestable(target) { model, error in
            if let error = error {
                completion(.error(error))
                return
            }

            guard let model = model else {
                completion(.empty)
                return
            }

            // 保存缓存
            saveCacheData(target, model)

            completion(.fresh(model))
        }
    }
    
    /// 加载缓存
    static func loadCacheData(_ target: CustomTargetType) -> DataState<Self>? {
        guard let policy = target as? NetworkCachePolicy,
              policy.cacheStrategy != .networkOnly else {
            return nil
        }
        
        switch policy.securityLevel {
        case .normal:
            if let wrapper = NetworkCache.load(Self.self, for: target.cacheKey),
               policy.cacheStrategy.shouldInvalidateCache(wrapper.cacheTime) == false {
                return .cache(wrapper.value)
            }
        case .encrypted:
            if let wrapper = EncryptedCache.load(Self.self, for: target.cacheKey),
               policy.cacheStrategy.shouldInvalidateCache(wrapper.cacheTime) == false {
                return .cache(wrapper.value)
            }
        default:
            break
        }
        
        return nil
    }
    
    /// 保存缓存
    static func saveCacheData(_ target: CustomTargetType, _ model: Self) {
        guard let policy = target as? NetworkCachePolicy,
              policy.cacheStrategy != .networkOnly else {
            return
        }
        
        switch policy.securityLevel {
        case .normal:
            NetworkCache.save(model, for: target.cacheKey)
        case .encrypted:
            EncryptedCache.save(model, for: target.cacheKey)
        default:
            break
        }
    }
}
