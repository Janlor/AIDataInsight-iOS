//
//  FunctionModel.swift
//  ModuleAI
//
//  Created by Janlor on 2024/10/29.
//

import Foundation
import BaseKit
import Networking

/// 基础查询模型 (适用于应收相关查询)
struct BasicQueryModel: Codable, Hashable, DictionaryConvertible {
    /// 公司id
    let orgId: Int?
    /// 客户名称
    let customerName: String?
    /// 排序方式
    let orderType: String?
    /// 运算符
    let `operator`: String?
    /// 运算值，当输入为万元时自动转换成元，操作符为IN或者NOT IN 时，当前的value会为多个值 使用逗号·,·隔开 例如：·100,200,500·
    let value: Double?
}

/// 时间范围查询模型 (适用于业绩相关查询)
struct TimeRangeQueryModel: Codable, Hashable, DictionaryConvertible {
    /// 查询周期中的起始日期，格式为yyyy-MM-dd
    let startDate: String?
    /// 查询周期中的终止日期，格式为yyyy-MM-dd
    let endDate: String?
    /// 公司id
    let orgId: Int?
    /// 客户名称
    let customerName: String?
    /// 商品类别，煤炭：13001 钢材：14001 有色：24001 其他：25001
    let goodsType: Int?
    /// 排序方式
    let orderType: String?
    /// 运算符
    let `operator`: String?
    /// 运算值，当输入为万元时自动转换成元，操作符为IN或者NOT IN 时，当前的value会为多个值 使用逗号·,·隔开 例如：·100,200,500·
    let value: Double?
}

/// 仓库查询模型 (适用于库存相关查询)
struct WarehouseQueryModel: Codable, Hashable, DictionaryConvertible {
    /// 公司id
    let orgId: Int?
    /// 仓库名称
    let warehouseName: String?
    /// 商品类别，煤炭：13001 钢材：14001 有色：24001 其他：25001
    let goodsType: Int?
    /// 排序方式
    let orderType: String?
    /// 运算符
    let `operator`: String?
    /// 运算值，当输入为万元时自动转换成元，操作符为IN或者NOT IN 时，当前的value会为多个值 使用逗号·,·隔开 例如：·100,200,500·
    let value: Double?
}

/// 账龄查询模型 (适用于账龄数组查询)
struct AccountAgeQueryModel: Codable, Hashable, DictionaryConvertible {
    /// 公司id
    let orgId: Int?
    /// 客户名称
    let customerName: String?
    /// 排序方式
    let orderType: String?
    /// 账龄
    let valueArray: [String]?
}

struct PerformanceTypeQueryModel: Codable, Hashable {
    /// 指标类别，1：销售额 2：采购额
    let indexType: String?
}

struct FunctionName: Codable, Hashable, RawRepresentable {
    let rawValue: String
    
    init?(rawValue: String) {
        self.rawValue = rawValue
    }
    
    // 应收
    static let queryArGroupByOrg = FunctionName(rawValue: "queryArGroupByOrg")!
    static let queryArGroupByCustomer = FunctionName(rawValue: "queryArGroupByCustomer")!
    
    // 业绩
    static let querySalesGroupByOrgAndGoodsType = FunctionName(rawValue: "querySalesGroupByOrgAndGoodsType")!
    static let querySalesGroupByMonth = FunctionName(rawValue: "querySalesGroupByMonth")!
    static let querySalesGroupByCustomer = FunctionName(rawValue: "querySalesGroupByCustomer")!
    static let queryPurchaseGroupByOrg = FunctionName(rawValue: "queryPurchaseGroupByOrg")!
    static let queryPurchaseGroupByMonth = FunctionName(rawValue: "queryPurchaseGroupByMonth")!
    static let queryPurchaseGroupByCustomer = FunctionName(rawValue: "queryPurchaseGroupByCustomer")!
    
    // 库存
    static let queryStockGroupByOrg = FunctionName(rawValue: "queryStockGroupByOrg")!
    static let queryStockGroupByWarehouse = FunctionName(rawValue: "queryStockGroupByWarehouse")!
    static let queryInventoryGroupByOrg = FunctionName(rawValue: "queryInventoryGroupByOrg")!
    static let queryInventoryGroupByWarehouse = FunctionName(rawValue: "queryInventoryGroupByWarehouse")!
    
    // 代采
    static let queryProcurementGroupByOrg = FunctionName(rawValue: "queryProcurementGroupByOrg")!
    static let queryProcurementGroupByCustomer = FunctionName(rawValue: "queryProcurementGroupByCustomer")!
    
    // 账龄
    static let queryAccountAgeGroupByOrg = FunctionName(rawValue: "queryAccountAgeGroupByOrg")!
    static let queryAccountAgeGroupByCustomer = FunctionName(rawValue: "queryAccountAgeGroupByCustomer")!
    static let queryAccountGroupByAge = FunctionName(rawValue: "queryAccountGroupByAge")!
    
    // 指标
    static let queryPerformanceType = FunctionName(rawValue: "queryPerformanceType")!
}

struct FunctionModel: Codable, NetworkRequestable {
    /// 历史会话 ID
    let historyId: Int?
    /// 是否存在函数调用
    let hasTool: Bool?
    /// 函数名称
    let name: FunctionName?
    /// 消息
    let msg: String?
    /// 参数
    let arguments: Codable?
    
    static func argumentsType(name: FunctionName?) -> Codable.Type? {
        guard let name = name else { return nil }
        switch name {
        case .queryArGroupByOrg, .queryArGroupByCustomer, .queryAccountGroupByAge:
            return BasicQueryModel.self
        case .querySalesGroupByOrgAndGoodsType, .querySalesGroupByMonth, .querySalesGroupByCustomer, .queryPurchaseGroupByOrg, .queryPurchaseGroupByMonth, .queryPurchaseGroupByCustomer:
            return TimeRangeQueryModel.self
        case .queryStockGroupByOrg, .queryStockGroupByWarehouse, .queryInventoryGroupByOrg, .queryInventoryGroupByWarehouse,
        .queryProcurementGroupByOrg, .queryProcurementGroupByCustomer:
            return WarehouseQueryModel.self
        case .queryAccountAgeGroupByOrg, .queryAccountAgeGroupByCustomer:
            return AccountAgeQueryModel.self
        case .queryPerformanceType:
            return PerformanceTypeQueryModel.self
        default:
            return nil
        }
    }
    
    enum CodingKeys: CodingKey {
        case historyId, hasTool, name, msg, arguments
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.historyId = try container.decodeIfPresent(Int.self, forKey: .historyId)
        self.hasTool = try container.decodeIfPresent(Bool.self, forKey: .hasTool)
        self.name = try container.decodeIfPresent(FunctionName.self, forKey: .name)
        self.msg = try container.decodeIfPresent(String.self, forKey: .msg)
        
        // 根据 name 的值和 argumentsType 动态解码 arguments
        if let name = self.name, let type = FunctionModel.argumentsType(name: name) {
            self.arguments = try container.decode(type, forKey: .arguments)
        } else {
            self.arguments = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(historyId, forKey: .historyId)
        try container.encodeIfPresent(hasTool, forKey: .hasTool)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(msg, forKey: .msg)

        // arguments：动态类型，对称 encode
        if let arguments = arguments {
            try container.encode(AnyEncodable(arguments), forKey: .arguments)
        }
    }

}
