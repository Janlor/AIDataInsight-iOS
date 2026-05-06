//
//  FunctionName.swift
//  ModuleAI
//
//  Created by Codex on 2026/1/1.
//

import Foundation

struct FunctionName: Codable, Hashable, RawRepresentable {
    let rawValue: String
    
    init?(rawValue: String) {
        self.rawValue = rawValue
    }
    
    static let queryArGroupByOrg = FunctionName(rawValue: "queryArGroupByOrg")!
    static let queryArGroupByCustomer = FunctionName(rawValue: "queryArGroupByCustomer")!
    
    static let querySalesGroupByOrgAndGoodsType = FunctionName(rawValue: "querySalesGroupByOrgAndGoodsType")!
    static let querySalesGroupByMonth = FunctionName(rawValue: "querySalesGroupByMonth")!
    static let querySalesGroupByCustomer = FunctionName(rawValue: "querySalesGroupByCustomer")!
    static let queryPurchaseGroupByOrg = FunctionName(rawValue: "queryPurchaseGroupByOrg")!
    static let queryPurchaseGroupByMonth = FunctionName(rawValue: "queryPurchaseGroupByMonth")!
    static let queryPurchaseGroupByCustomer = FunctionName(rawValue: "queryPurchaseGroupByCustomer")!
    
    static let queryStockGroupByOrg = FunctionName(rawValue: "queryStockGroupByOrg")!
    static let queryStockGroupByWarehouse = FunctionName(rawValue: "queryStockGroupByWarehouse")!
    static let queryInventoryGroupByOrg = FunctionName(rawValue: "queryInventoryGroupByOrg")!
    static let queryInventoryGroupByWarehouse = FunctionName(rawValue: "queryInventoryGroupByWarehouse")!
    
    static let queryProcurementGroupByOrg = FunctionName(rawValue: "queryProcurementGroupByOrg")!
    static let queryProcurementGroupByCustomer = FunctionName(rawValue: "queryProcurementGroupByCustomer")!
    
    static let queryAccountAgeGroupByOrg = FunctionName(rawValue: "queryAccountAgeGroupByOrg")!
    static let queryAccountAgeGroupByCustomer = FunctionName(rawValue: "queryAccountAgeGroupByCustomer")!
    static let queryAccountGroupByAge = FunctionName(rawValue: "queryAccountGroupByAge")!
    
    static let queryPerformanceType = FunctionName(rawValue: "queryPerformanceType")!
}
