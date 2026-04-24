//
//  UserOrgProtocal.swift
//  LibraryBasics
//
//  Created by Janlor on 2026/1/12.
//

import Foundation

public protocol UserOrgProtocal {
    var id: Int? { get set }
    var name: String? { get set }
}

public struct UserOrgModel: UserOrgProtocal, Codable, Hashable {
    public var id: Int?
    public var name: String?
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
