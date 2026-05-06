//
//  History.swift
//  ModuleAI
//
//  Created by Janlor on 2024/10/24.
//

import Foundation
import BaseKit
import Networking

/// 主数据模型
struct RecordPageModel: Codable, Hashable, Equatable, NetworkRequestable {
    /// 当前页码
    let currentPage: Int?
    /// 每页大小
    let pageSize: Int?
    /// 总记录数
    let total: Int?
    /// 总页数
    let pages: Int?
    /// 缓存键
    let cacheKey: String?
    /// 记录列表
    let records: [RecordModel]?
}

/// 单条记录
struct RecordModel: Codable, Hashable, Equatable, NetworkRequestable {
    /// 记录 ID
    let id: Int?
    /// 会话名称
    let name: String?
    /// 创建人 ID
    let createId: Int?
    /// 更新人 ID
    let updateId: Int?
    /// 创建人名称
    let createName: String?
    /// 更新人名称
    let updateName: String?
    /// 创建时间
    let createTime: String?
    /// 更新时间
    let updateTime: String?
    /// 详情列表
    let detailList: [DetailModel]?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: RecordModel, rhs: RecordModel) -> Bool {
        return lhs.id == rhs.id
    }
}

struct DetailType: Codable, Hashable, Equatable, RawRepresentable {
    let rawValue: String

    static let question = DetailType(rawValue: "1")
    static let answer = DetailType(rawValue: "2")
}

struct ContentType: Codable, Hashable, Equatable, RawRepresentable {
    let rawValue: String

    static let ai = ContentType(rawValue: "1")
    static let chart = ContentType(rawValue: "2")
}

/// 详情项
struct DetailModel: Codable, Hashable, Equatable {
    /// 详情 ID
    let id: Int?
    /// 会话历史 ID
    let historyId: Int?
    /// 会话类型 (1-问题, 2-回答)
    let type: DetailType?
    /// 内容类型1-ai 2-chart
    let contentType: ContentType?
    /// 会话内容
    let content: String?
    /// 是否点赞 (1-赞, 0-踩)
    let isLike: String?
    /// 创建时间
    let createTime: String?
    /// 更新时间
    let updateTime: String?
    
    /// 手动转的模型
    @CodableIgnored var chatModel: HistoryDetailModel?
    /// 手动转的模型
    @CodableIgnored var funcModel: FunctionModel?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: DetailModel, rhs: DetailModel) -> Bool {
        return lhs.id == rhs.id
    }
}

extension DetailModel {
    static func decodeDetailList(_ detailList: [DetailModel]) -> [DetailModel] {
        var result: [DetailModel] = []
        for detail in detailList {
            // 只处理AI消息
            guard let type = detail.type,
                  type == .answer else {
                result.append(detail)
                continue
            }
            
            // 不支持的消息类型
            guard let content = detail.content,
                  let contentType = detail.contentType,
                  let data = content.data(using: .utf8) else {
                result.append(detail)
                continue
            }

            switch contentType {
            case .ai: // function 接口的报错消息
                if let model = try? appDecoder.decode(FunctionModel.self, from: data) {
                    var newDetail = detail
                    newDetail.funcModel = model
                    result.append(newDetail)
                    continue
                }
            case .chart: // 图表数据接口的返回数据
                if var model = try? appDecoder.decode(HistoryDetailModel.self, from: data) {
                    var newDetail = detail
                    model.historyDetailId = detail.id
                    newDetail.chatModel = model
                    result.append(newDetail)
                    continue
                }
                
            default:
                // 不支持的消息类型
                result.append(detail)
                continue
            }
        }
        return result
    }
}
