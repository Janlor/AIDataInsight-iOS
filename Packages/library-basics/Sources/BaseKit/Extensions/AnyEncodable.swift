//
//  AnyEncodable.swift
//  LibraryBasics
//
//  Created by Janlor on 4/22/26.
//

import Foundation

public struct AnyEncodable: Encodable {
    private let encodeClosure: (Encoder) throws -> Void

    public init<T: Encodable>(_ value: T) {
        self.encodeClosure = value.encode
    }

    public func encode(to encoder: Encoder) throws {
        try encodeClosure(encoder)
    }
}
