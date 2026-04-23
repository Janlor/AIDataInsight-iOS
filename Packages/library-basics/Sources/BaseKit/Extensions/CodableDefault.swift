//
//  CodableDefault.swift
//  ModuleStatistic
//
//  Created by Janlor on 4/22/26.
//

import UIKit

public protocol DefaultValue {
    associatedtype Value: Codable
    static var defaultValue: Value { get }
}

@propertyWrapper
public struct Default<T: DefaultValue> {
    public var wrappedValue: T.Value
    
    public init(wrappedValue: T.Value) {
        self.wrappedValue = wrappedValue
    }
}

extension Default: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        wrappedValue = (try? container.decode(T.Value.self)) ?? T.defaultValue
    }
}

// 新增 Encodable 的支持
extension Default: Encodable {
    public func encode(to encoder: Encoder) throws {
        // 在这里不执行编码，从而忽略该属性
    }
}

public extension KeyedDecodingContainer {
    func decode<T>(
        _ type: Default<T>.Type,
        forKey key: Key
    ) throws -> Default<T> where T: DefaultValue {
        try decodeIfPresent(type, forKey: key) ?? Default(wrappedValue: T.defaultValue)
    }
}

// Bool 的扩展
public extension Bool {
    enum False: DefaultValue {
        public static let defaultValue = false
    }
    enum True: DefaultValue {
        public static let defaultValue = true
    }
}

public extension Default {
    typealias True = Default<Bool.True>
    typealias False = Default<Bool.False>
}

// 扩展 UUID 以支持 DefaultValue 协议
extension UUID: DefaultValue {
    public static var defaultValue: UUID {
        return UUID()
    }
}

// 扩展 String 以支持 DefaultValue 协议
extension String: DefaultValue {
    public static var defaultValue: String {
        return UUID().uuidString
    }
}

// 扩展 Int 以支持 DefaultValue 协议
extension Int: DefaultValue {
    public static var defaultValue: Int {
        return 0
    }
}

//// 测试结构体
//struct Video: Codable {
//    enum State: String, Codable, DefaultValue {
//        case streaming
//        case archived
//        case unknown
//
//        static let defaultValue = Video.State.unknown
//    }
//
//    let id: Int
//    let title: String
//
//    @Default.False var commentEnabled: Bool
//    @Default.True var publicVideo: Bool
//
//    @Default<State> var state: State
//}
//
//// 测试编码和解码
//let json = #"{"id": 12345, "title": "My First Video", "state": "reserved"}"#
//let value = try! JSONDecoder().decode(Video.self, from: json.data(using: .utf8)!)
//print(value)
//
//let encoded = try! JSONEncoder().encode(value)
//print(String(data: encoded, encoding: .utf8)!)  // 编码结果不包含 commentEnabled, publicVideo, state

