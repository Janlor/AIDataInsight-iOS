//
//  FunctionQueryModels.swift
//  ModuleAI
//
//  Created by Codex on 2026/1/1.
//

import Foundation
import BaseKit

struct BasicQueryModel: Codable, Hashable, DictionaryConvertible {
    let orgId: Int?
    let customerName: String?
    let orderType: String?
    let `operator`: String?
    let value: Double?
}

struct TimeRangeQueryModel: Codable, Hashable, DictionaryConvertible {
    let startDate: String?
    let endDate: String?
    let orgId: Int?
    let customerName: String?
    let goodsType: Int?
    let orderType: String?
    let `operator`: String?
    let value: Double?
}

struct WarehouseQueryModel: Codable, Hashable, DictionaryConvertible {
    let orgId: Int?
    let warehouseName: String?
    let goodsType: Int?
    let orderType: String?
    let `operator`: String?
    let value: Double?
}

struct AccountAgeQueryModel: Codable, Hashable, DictionaryConvertible {
    let orgId: Int?
    let customerName: String?
    let orderType: String?
    let valueArray: [String]?
}

struct PerformanceTypeQueryModel: Codable, Hashable {
    let indexType: String?
}
