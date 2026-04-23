//
//  ChartApi.swift
//  Pods
//
//  Created by Janlor on 4/22/26.
//

import Foundation
import BaseKit
import Networking

enum ChartApi: CustomTargetType {
    /// 17个数据接口
    case chart(String, Int, DictionaryConvertible)
    
//    /// 查询各公司的应收情况（按公司维度）
//    case queryArGroupByOrg(BasicQueryModel)
//    /// 查询各公司的应收情况（按客户维度）
//    case queryArGroupByCustomer(BasicQueryModel)
//
//    /// 查询公司销售额（按公司维度+商品类别）
//    case querySalesGroupByOrgAndGoodsType(TimeRangeQueryModel)
//    /// 查询公司销售额（按月纬度）
//    case querySalesGroupByMonth(TimeRangeQueryModel)
//    /// 查询公司销售额（按客户维度）
//    case querySalesGroupByCustomer(TimeRangeQueryModel)
//    /// 查询公司采购额（按公司维度）
//    case queryPurchaseGroupByOrg(TimeRangeQueryModel)
//    /// 查询公司采购额（按月纬度）
//    case queryPurchaseGroupByMonth(TimeRangeQueryModel)
//    /// 查询公司采购额（按客户维度）
//    case queryPurchaseGroupByCustomer(TimeRangeQueryModel)
//
//    /// 查询库存存量（按公司维度）
//    case queryStockGroupByOrg(WarehouseQueryModel)
//    /// 查询库存存量（按仓库维度）
//    case queryStockGroupByWarehouse(WarehouseQueryModel)
//    /// 查询存货金额（按公司维度）
//    case queryInventoryGroupByOrg(WarehouseQueryModel)
//    /// 查询存货金额（按仓库维度）
//    case queryInventoryGroupByWarehouse(WarehouseQueryModel)
//
//    /// 查询公司代采业务情况（按公司维度统计）
//    case queryProcurementGroupByOrg(WarehouseQueryModel)
//    /// 查询代采业务客户情况（按客户维度统计）
//    case queryProcurementGroupByCustomer(WarehouseQueryModel)
//
//    /// 查询各公司的账龄情况（按公司维度）
//    case queryAccountAgeGroupByOrg(AccountAgeQueryModel)
//    /// 查询各公司的账龄情况（按客户维度）
//    case queryAccountAgeGroupByCustomer(AccountAgeQueryModel)
//    /// 查询不同账龄区间的账龄金额（按账龄维度）
//    case queryAccountGroupByAge(BasicQueryModel)
    
    var path: String {
        switch self {
        case .chart(let name, _, _):
            return "/chart/\(name)"
//        case .queryArGroupByOrg(_):
//            return "/chart/queryArGroupByOrg"
//        case .queryArGroupByCustomer(_):
//            return "/chart/queryArGroupByCustomer"
//        case .querySalesGroupByOrgAndGoodsType(_):
//            return "/chart/querySalesGroupByOrgAndGoodsType"
//        case .querySalesGroupByMonth(_):
//            return "/chart/querySalesGroupByMonth"
//        case .querySalesGroupByCustomer(_):
//            return "/chart/querySalesGroupByCustomer"
//        case .queryPurchaseGroupByOrg(_):
//            return "/chart/queryPurchaseGroupByOrg"
//        case .queryPurchaseGroupByMonth(_):
//            return "/chart/queryPurchaseGroupByMonth"
//        case .queryPurchaseGroupByCustomer(_):
//            return "/chart/queryPurchaseGroupByCustomer"
//        case .queryStockGroupByOrg(_):
//            return "/chart/queryStockGroupByOrg"
//        case .queryStockGroupByWarehouse(_):
//            return "/chart/queryStockGroupByWarehouse"
//        case .queryInventoryGroupByOrg(_):
//            return "/chart/queryInventoryGroupByOrg"
//        case .queryInventoryGroupByWarehouse(_):
//            return "/chart/queryInventoryGroupByWarehouse"
//        case .queryProcurementGroupByOrg(_):
//            return "/chart/queryProcurementGroupByOrg"
//        case .queryProcurementGroupByCustomer(_):
//            return "/chart/queryProcurementGroupByCustomer"
//        case .queryAccountAgeGroupByOrg(_):
//            return "/chart/queryAccountAgeGroupByOrg"
//        case .queryAccountAgeGroupByCustomer(_):
//            return "/chart/queryAccountAgeGroupByCustomer"
//        case .queryAccountGroupByAge(_):
//            return "/chart/queryAccountGroupByAge"
        }
    }
    
    var method: Networking.Method {
        return .get
    }
    
    var parameters: [String : Any] {
        switch self {
        case .chart(_, let historyId, let queryModel):
            var params = queryModel.toDictionary()
            params["historyId"] = historyId
            return params
//        case .queryArGroupByOrg(let queryModel):
//            return queryModel.toDictionary()
//        case .queryArGroupByCustomer(let queryModel):
//            return queryModel.toDictionary()
//        case .querySalesGroupByOrgAndGoodsType(let queryModel):
//            return queryModel.toDictionary()
//        case .querySalesGroupByMonth(let queryModel):
//            return queryModel.toDictionary()
//        case .querySalesGroupByCustomer(let queryModel):
//            return queryModel.toDictionary()
//        case .queryPurchaseGroupByOrg(let queryModel):
//            return queryModel.toDictionary()
//        case .queryPurchaseGroupByMonth(let queryModel):
//            return queryModel.toDictionary()
//        case .queryPurchaseGroupByCustomer(let queryModel):
//            return queryModel.toDictionary()
//        case .queryStockGroupByOrg(let queryModel):
//            return queryModel.toDictionary()
//        case .queryStockGroupByWarehouse(let queryModel):
//            return queryModel.toDictionary()
//        case .queryInventoryGroupByOrg(let queryModel):
//            return queryModel.toDictionary()
//        case .queryInventoryGroupByWarehouse(let queryModel):
//            return queryModel.toDictionary()
//        case .queryProcurementGroupByOrg(let queryModel):
//            return queryModel.toDictionary()
//        case .queryProcurementGroupByCustomer(let queryModel):
//            return queryModel.toDictionary()
//        case .queryAccountAgeGroupByOrg(let queryModel):
//            return queryModel.toDictionary()
//        case .queryAccountAgeGroupByCustomer(let queryModel):
//            return queryModel.toDictionary()
//        case .queryAccountGroupByAge(let queryModel):
//            return queryModel.toDictionary()
        }
    }
}
