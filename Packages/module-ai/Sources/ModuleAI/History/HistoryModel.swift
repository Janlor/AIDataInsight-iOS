//
//  History.swift
//  ModuleAI
//
//  Created by Janlor on 2024/10/24.
//

import Foundation
import UIKit
import BaseKit
import BaseUI
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
    
    @CodableIgnored var localDateTime: String?
    @CodableIgnored var localAttributedText: NSAttributedString?
    
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

extension RecordModel {
    // 分组方法
    static func groupRecordsByDate(records: [RecordModel]?, dateFormatter: DateFormatter? = nil) -> [[RecordModel]] {
        guard let records = records else { return [] }
        
        let dateFormatter = dateFormatter ?? {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            return formatter
        }()
        
        let calendar = Calendar.current
        var groupedRecords: [[RecordModel]] = []
        var currentGroup: [RecordModel] = []
        var currentGroupKey: String?
        
        for record in records {
            guard let date = dateFormatter.date(from: record.updateTime ?? "") else { continue }
            
            let group = groupKeyForDate(date, calendar: calendar)
            let groupKey = group.0
            let dateTimeRange = group.1
            
            var newRecord = record
            newRecord.localDateTime = localTime(dateTime: record.updateTime, range: dateTimeRange)
            newRecord.localAttributedText = localAttributedText(name: record.name, time: newRecord.localDateTime)
            
            if groupKey != currentGroupKey {
                if !currentGroup.isEmpty {
                    groupedRecords.append(currentGroup)
                }
                currentGroup = [newRecord]
                currentGroupKey = groupKey
            } else {
                currentGroup.append(newRecord)
            }
        }
        
        if !currentGroup.isEmpty {
            groupedRecords.append(currentGroup)
        }
        
        return groupedRecords
    }
    
    // 合并方法
    static func mergeGroupedRecords(existing: inout [[RecordModel]], new: [[RecordModel]], dateFormatter: DateFormatter? = nil) {
        let calendar = Calendar.current
        
        for newGroup in new {
            if let firstRecord = newGroup.first, let date = dateFormatter?.date(from: firstRecord.updateTime ?? "") {
                let groupKey = groupKeyForDate(date, calendar: calendar).0
                
                // 查找是否存在相同日期的组
                if let existingGroupIndex = existing.lastIndex(where: { group in
                    guard let firstInGroup = group.first, let existingDate = dateFormatter?.date(from: firstInGroup.updateTime ?? "") else { return false }
                    return groupKey == groupKeyForDate(existingDate, calendar: calendar).0
                }) {
                    // 如果存在相同日期的组，合并记录
                    existing[existingGroupIndex].append(contentsOf: newGroup)
                } else {
                    // 如果不存在相同日期的组，添加新组
                    existing.append(newGroup)
                }
            }
        }
    }
    
    // 抽取的辅助方法
    static func groupKeyForDate(_ date: Date, calendar: Calendar) -> (String, ClosedRange<Int>) {
        if calendar.isDateInToday(date) {
            return (NSLocalizedString("今天", bundle: .module, comment: ""), 11...15)
//        } else if calendar.isDateInYesterday(date) {
//            return "昨天"
        } else if calendar.isDate(date, equalTo: Date(), toGranularity: .month) {
            return (NSLocalizedString("本月", bundle: .module, comment: ""), 5...9)
//        } else if calendar.isDate(date, equalTo: Date(), toGranularity: .year) {
//            return "本年"
        } else {
            return (NSLocalizedString("其它", bundle: .module, comment: ""), 0...9)
//            let year = calendar.component(.year, from: date)
//            return "\(year)年"
        }
    }
    
    static func localTime(dateTime: String?, range: ClosedRange<Int>) -> String {
        guard let dateString = dateTime, dateString.count > range.upperBound else { return "" }
        let startIndex = dateString.index(dateString.startIndex, offsetBy: range.lowerBound)
        let endIndex = dateString.index(dateString.startIndex, offsetBy: range.upperBound)
        return String(dateString[startIndex...endIndex])
    }
    
    static func localAttributedText(name: String?, time: String?) -> NSAttributedString {
        let title = (name ?? "") + " "
        let date = time ?? ""
        let titleText = AIChatRichText(text: title, attributes: [
            .foregroundColor: UIColor.theme.secondaryLabel,
            .font: UIFont.theme.subhead
        ])
        let dateText = AIChatRichText(text: date, attributes: [
            .foregroundColor: UIColor.theme.tertieryLabel,
            .font: UIFont.theme.caption1
        ])
        return AIChatRichText.attributedString(from: [titleText, dateText])
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
