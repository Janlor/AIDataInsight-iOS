//
//  SubSysProtocol.swift
//  LibraryBasics
//
//  Created by Janlor on 2026/1/12.
//

import Foundation

public protocol SubSysProtocol {
    var id: SubSysId? { get set }
    var name: String? { get set }
}

public struct SubSysId: RawRepresentable, Codable, Hashable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let coal = SubSysId(rawValue: 13001)
    public static let steel = SubSysId(rawValue: 14001)
    public static let standard = SubSysId(rawValue: 24001)
    public static let others = SubSysId(rawValue: 25001)
}

public struct SubSystemModel: SubSysProtocol, Codable, Hashable {
    public var id: SubSysId?
    public var name: String?

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: SubSystemModel, rhs: SubSystemModel) -> Bool {
        return lhs.id == rhs.id
    }
}

public extension SubSystemModel {
    /// 筛选出支持的类型
    static func filteredBusiness(_ models: inout [SubSystemModel]) {
        let filters: [SubSysId] = [.coal, .steel, .standard, .others]
        models = models.filter { model in
            if let id = model.id {
                return filters.contains(id)
            }
            return false
        }
    }
}
