//
//  HistoryDetailModel.swift
//  ModuleAI
//
//  Created by Janlor on 2024/10/30.
//

import Foundation
import Networking

/// 新的会话历史明细模型
struct HistoryDetailModel: Codable, Hashable, Equatable, NetworkRequestable {
    /// 方法类型（传方法名）
    let funcType: FunctionName?
    /// 会话历史明细 ID
    var historyDetailId: Int?
    /// 通用返回信息列表
    let chartCommonVoList: [ChartCommonVo]?
    /// 多区间账龄返回数据列表
    let accountAgeGroupVoList: [AccountAgeGroupVo]?
}

/// 通用返回信息项
struct ChartCommonVo: Codable, Hashable, Equatable {
    /// 业务 ID
    let bizId: String?
    /// 名称
    let name: String?
    /// 值
    let value: Double?
}

/// 多区间账龄返回数据项
struct AccountAgeGroupVo: Codable, Hashable, Equatable {
    /// 名称
    let name: String?
    /// 值数组
    let valueList: [Double]?
    /// 标签列表
    let labelList: [String]?
    /// 提示信息
    let msg: String?
    /// 返回数据类型 1。图表 2。提示信息
    let chartType: String?
}
