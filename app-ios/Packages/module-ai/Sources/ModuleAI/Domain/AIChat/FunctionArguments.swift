//
//  FunctionArguments.swift
//  ModuleAI
//
//  Created by Codex on 2026/1/1.
//

import Foundation
import BaseKit

enum FunctionArguments: Hashable {
    case basic(BasicQueryModel)
    case timeRange(TimeRangeQueryModel)
    case warehouse(WarehouseQueryModel)
    case accountAge(AccountAgeQueryModel)
    case performanceType(PerformanceTypeQueryModel)
}

extension FunctionArguments: DictionaryConvertible {
    func toDictionary() -> [String : Any] {
        switch self {
        case .basic(let model):
            return model.toDictionary()
        case .timeRange(let model):
            return model.toDictionary()
        case .warehouse(let model):
            return model.toDictionary()
        case .accountAge(let model):
            return model.toDictionary()
        case .performanceType(let model):
            return ["indexType": model.indexType as Any]
        }
    }
}
