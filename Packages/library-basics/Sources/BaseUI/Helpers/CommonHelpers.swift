//
//  Helpers.swift
//  Pods
//
//  Created by Janlor on 4/22/26.
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

public let appDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = .current
    formatter.timeZone = .current
    return formatter
}()
