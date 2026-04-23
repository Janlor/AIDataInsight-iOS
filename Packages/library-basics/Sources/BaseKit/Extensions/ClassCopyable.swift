//
//  ClassCopyable.swift
//  LibraryBasics
//
//  Created by Janlor on 4/22/26.
//

import Foundation

/// 为 Class 增加深拷贝能力 Realm Object 类不可用
public protocol ClassCopyable: AnyObject, Codable {
    func copy() -> Self
}

public extension ClassCopyable {
    func copy() -> Self {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(self) else {
            fatalError("encode失败")
        }
        let decoder = JSONDecoder()
        guard let target = try? decoder.decode(Self.self, from: data) else {
            fatalError("decode失败")
        }
        return target
    }
}

// 为包含 ClassCopyable 元素的数组添加深拷贝功能
public extension Array where Element: ClassCopyable {
    func deepCopy() -> [Element] {
        return self.map { $0.copy() }
    }
}
