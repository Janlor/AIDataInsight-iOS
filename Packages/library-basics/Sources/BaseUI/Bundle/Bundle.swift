//
//  Bundle.swift
//  TabBar
//
//  Created by Janlor on 4/22/26.
//
import UIKit
import BaseKit

private class Point: NSObject {}

extension UIImage {
    class func imageNamed(for name: String?) -> UIImage? {
        return UIImage(named: name ?? "", in: Bundle.module, compatibleWith: nil)
    }
}

extension Bundle {
    private static var cachedBundle: Bundle?

    class func current() -> Bundle? {
        if let bundle = cachedBundle {
            return bundle
        }
        let bundle = Bundle.currentBundle(currentName: "BaseUI", temp: Point.self)
        cachedBundle = bundle
        return bundle
    }
}

// 创建一个全局的 NSCache 实例来缓存本地化字符串
private let localizedStringCache = NSCache<NSString, NSString>()

public func LibLocalizedString(_ key: String, tableName: String? = nil, value: String = "", comment: String = "") -> String {
    let cacheKey = "\(key)-\(tableName ?? "")" as NSString
    
    // 先检查 NSCache 中是否已有该字符串
    if let cachedString = localizedStringCache.object(forKey: cacheKey) {
        return cachedString as String
    }

    // 获取当前 Bundle，如果没有就使用主 Bundle
    let bundle = Bundle.module
    let localizedString = NSLocalizedString(key, tableName: tableName, bundle: bundle, value: value, comment: comment) as NSString
    
    // 将查找到的字符串存入 NSCache
    localizedStringCache.setObject(localizedString, forKey: cacheKey)
    
    return localizedString as String
}
