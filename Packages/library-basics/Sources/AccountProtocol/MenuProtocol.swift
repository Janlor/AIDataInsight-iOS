//
//  MenuProtocol.swift
//  LibraryBasics
//
//  Created by Janlor on 4/22/26.
//

import Foundation

public protocol MenuProtocol {
    var id: MenuId? { get set }
    var name: String? { get set }
}

public struct MenuId: RawRepresentable, Codable, Hashable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let group = MenuId(rawValue: 9002)
    public static let company = MenuId(rawValue: 9003)
    public static let approval = MenuId(rawValue: 9004)
    public static let message = MenuId(rawValue: 9005)
}

public struct MenuModel: MenuProtocol, Codable, Hashable {
    public var id: MenuId?
    public var name: String?
    
    public init(id: MenuId? = nil, name: String? = nil) {
        self.id = id
        self.name = name
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}

