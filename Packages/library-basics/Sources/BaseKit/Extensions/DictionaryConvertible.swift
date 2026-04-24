//
//  DictionaryConvertible.swift
//  Pods
//
//  Created by Janlor on 6/3/24.
//

import Foundation

public protocol CodableIgnoredProtocol {}

extension CodableIgnored: CodableIgnoredProtocol {}

public protocol DictionaryConvertible {
    func toDictionary() -> [String: Any]
}


public extension DictionaryConvertible {
    /// 将模型转换为字典
    func toDictionary() -> [String: Any] {
        let mirror = Mirror(reflecting: self)
        var dictionary: [String: Any] = [:]
        
        for case let (label?, value) in mirror.children {
            
            // 跳过 @CodableIgnored 字段
            if value is CodableIgnoredProtocol {
                continue
            }
            
            if let convertibleValue = value as? DictionaryConvertible {
                let convertedValue = convertibleValue.toDictionary()
                if !convertedValue.isEmpty {
                    dictionary[label] = convertedValue
                }
            } else if let arrayValue = value as? [DictionaryConvertible] {
                let convertedArray = arrayValue.map { $0.toDictionary() }.filter { !$0.isEmpty }
                if !convertedArray.isEmpty {
                    dictionary[label] = convertedArray
                }
            } else if let optionalValue = value as? OptionalProtocol {
                if optionalValue.hasValue {
                    dictionary[label] = optionalValue.wrappedValue()
                }
            } else {
                dictionary[label] = value
            }
        }
        
        return dictionary
    }
    
    /// 将模型数组转换为字典数组
    static func toDictionaryArray(models: [Self]) -> [[String: Any]] {
        return models.map { $0.toDictionary() }
    }
}

/// 用于检查 Optional 类型的协议
public protocol OptionalProtocol {
    var hasValue: Bool { get }
    func wrappedValue() -> Any
}

/// 扩展 Optional 以实现 OptionalProtocol
extension Optional: OptionalProtocol {
    public var hasValue: Bool {
        switch self {
        case .none:
            return false
        case .some:
            return true
        }
    }
    
    public func wrappedValue() -> Any {
        switch self {
        case .none:
            return NSNull() // This shouldn't be used, as we check hasValue first
        case .some(let wrapped):
            return wrapped
        }
    }
}
