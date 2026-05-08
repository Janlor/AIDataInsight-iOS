//
//  FunctionArgumentSchema.swift
//  ModuleAI
//
//  Created by Codex on 2026/05/08.
//

import Foundation

enum FunctionArgumentKind: Hashable {
    case basic
    case timeRange
    case warehouse
    case accountAge
    case performanceType
}

extension FunctionName {
    static let allCases: [FunctionName] = [
        .queryArGroupByOrg,
        .queryArGroupByCustomer,
        .querySalesGroupByOrgAndGoodsType,
        .querySalesGroupByMonth,
        .querySalesGroupByCustomer,
        .queryPurchaseGroupByOrg,
        .queryPurchaseGroupByMonth,
        .queryPurchaseGroupByCustomer,
        .queryStockGroupByOrg,
        .queryStockGroupByWarehouse,
        .queryInventoryGroupByOrg,
        .queryInventoryGroupByWarehouse,
        .queryProcurementGroupByOrg,
        .queryProcurementGroupByCustomer,
        .queryAccountAgeGroupByOrg,
        .queryAccountAgeGroupByCustomer,
        .queryAccountGroupByAge,
        .queryPerformanceType
    ]
    
    var argumentKind: FunctionArgumentKind? {
        switch self {
        case .queryArGroupByOrg, .queryArGroupByCustomer, .queryAccountGroupByAge:
            return .basic
        case .querySalesGroupByOrgAndGoodsType, .querySalesGroupByMonth, .querySalesGroupByCustomer,
             .queryPurchaseGroupByOrg, .queryPurchaseGroupByMonth, .queryPurchaseGroupByCustomer:
            return .timeRange
        case .queryStockGroupByOrg, .queryStockGroupByWarehouse, .queryInventoryGroupByOrg,
             .queryInventoryGroupByWarehouse, .queryProcurementGroupByOrg, .queryProcurementGroupByCustomer:
            return .warehouse
        case .queryAccountAgeGroupByOrg, .queryAccountAgeGroupByCustomer:
            return .accountAge
        case .queryPerformanceType:
            return .performanceType
        default:
            return nil
        }
    }
}

extension KeyedDecodingContainer {
    func decodeFunctionArguments(
        name: FunctionName?,
        forKey key: Key
    ) throws -> FunctionArguments? {
        guard let kind = name?.argumentKind else { return nil }
        
        switch kind {
        case .basic:
            return .basic(try decode(BasicQueryModel.self, forKey: key))
        case .timeRange:
            return .timeRange(try decode(TimeRangeQueryModel.self, forKey: key))
        case .warehouse:
            return .warehouse(try decode(WarehouseQueryModel.self, forKey: key))
        case .accountAge:
            return .accountAge(try decode(AccountAgeQueryModel.self, forKey: key))
        case .performanceType:
            return .performanceType(try decode(PerformanceTypeQueryModel.self, forKey: key))
        }
    }
}

