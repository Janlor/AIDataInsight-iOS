//
//  Helpers.swift
//  Pods
//
//  Created by Janlor on 5/29/24.
//

import Foundation

public let appDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
}()

public let appEncoder: JSONEncoder = {
    let encoder = JSONEncoder()
    return encoder
}()
