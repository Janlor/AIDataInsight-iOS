//
//  AIChatApplicationMapper.swift
//  ModuleAI
//
//  Created by Codex on 2026/05/08.
//

import Foundation

enum AIChatApplicationMapper {
    private static let chartFallbackMessage = "数据分析还在测试阶段，很快就能上线，敬请期待！"
    
    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    static func makeMessages(from detailList: [DetailModel]) -> [ConversationMessage] {
        detailList.map(mapToMessage)
    }
    
    static func makeChartPayload(from model: HistoryDetailModel) -> ChartPayload? {
        if let list = model.chartCommonVoList, !list.isEmpty {
            return ChartPayload(
                functionName: model.funcType,
                unit: unit(for: model.funcType),
                series: list.map { item in
                    let title = item.name ?? ""
                    return ChartSeries(
                        xAxis: title,
                        labels: [title],
                        values: [item.value ?? 0]
                    )
                },
                emptyMessage: nil
            )
        }
        
        if let list = model.accountAgeGroupVoList, !list.isEmpty {
            if let first = list.first,
               first.chartType == "2",
               let msg = first.msg {
                return ChartPayload(
                    functionName: model.funcType,
                    unit: unit(for: model.funcType),
                    series: [],
                    emptyMessage: msg
                )
            }
            
            return ChartPayload(
                functionName: model.funcType,
                unit: unit(for: model.funcType),
                series: list.map { item in
                    ChartSeries(
                        xAxis: item.name ?? "",
                        labels: item.labelList ?? [],
                        values: item.valueList ?? []
                    )
                },
                emptyMessage: nil
            )
        }
        
        return nil
    }
}

private extension AIChatApplicationMapper {
    static func mapToMessage(_ model: DetailModel) -> ConversationMessage {
        if model.type == .question {
            return ConversationMessage(
                id: messageId(from: model),
                role: .user,
                contentKind: .text,
                text: model.content ?? "",
                intentType: nil,
                chartPayload: nil,
                feedback: .none,
                historyDetailId: model.id,
                functionName: nil
            )
        }
        
        if let chartDetail = decodeHistoryDetail(from: model) {
            if let payload = makeChartPayload(from: chartDetail) {
                if payload.series.isEmpty == false {
                    return ConversationMessage(
                        id: messageId(from: model),
                        role: .assistant,
                        contentKind: .chart,
                        text: "根据您的查询，以下是分析结果:",
                        intentType: nil,
                        chartPayload: payload,
                        feedback: feedback(from: model.isLike),
                        historyDetailId: model.id,
                        functionName: chartDetail.funcType
                    )
                }
                
                return assistantTextMessage(
                    model,
                    text: payload.emptyMessage ?? Self.chartFallbackMessage
                )
            }
            
            return assistantTextMessage(model, text: Self.chartFallbackMessage)
        }
        
        if let functionModel = decodeFunctionModel(from: model) {
            return assistantTextMessage(model, text: functionModel.msg ?? "")
        }
        
        return assistantTextMessage(
            model,
            text: model.content ?? "新版本上线啦，升级后我会变得更聪明，快来体验吧！"
        )
    }
    
    static func assistantTextMessage(_ model: DetailModel, text: String) -> ConversationMessage {
        ConversationMessage(
            id: messageId(from: model),
            role: .assistant,
            contentKind: .text,
            text: text,
            intentType: nil,
            chartPayload: nil,
            feedback: feedback(from: model.isLike),
            historyDetailId: model.id,
            functionName: nil
        )
    }
    
    static func decodeFunctionModel(from model: DetailModel) -> FunctionModel? {
        guard model.type == .answer,
              model.contentType == .ai,
              let content = model.content,
              let data = content.data(using: .utf8) else {
            return nil
        }
        
        guard let dto = try? decoder.decode(HistoryFunctionContentDTO.self, from: data) else {
            return nil
        }
        
        return dto.toDomainModel()
    }
    
    static func decodeHistoryDetail(from model: DetailModel) -> HistoryDetailModel? {
        guard model.type == .answer,
              model.contentType == .chart,
              let content = model.content,
              let data = content.data(using: .utf8) else {
            return nil
        }
        
        return try? decoder.decode(HistoryDetailModel.self, from: data)
    }
    
    static func feedback(from isLike: String?) -> FeedbackState {
        switch isLike {
        case "1":
            return .liked
        case "0":
            return .disliked
        case nil:
            return .none
        default:
            return .unknown
        }
    }
    
    static func messageId(from model: DetailModel) -> String {
        if let id = model.id {
            return "history-detail-\(id)"
        }
        return UUID().uuidString
    }
    
    static func unit(for functionName: FunctionName?) -> ChartUnit {
        switch functionName {
        case .queryStockGroupByOrg, .queryStockGroupByWarehouse:
            return .ton
        default:
            return .currency
        }
    }
}

private struct HistoryFunctionContentDTO: Decodable {
    let historyId: Int?
    let hasTool: Bool?
    let name: FunctionName?
    let msg: String?
    let arguments: FunctionArguments?
    
    enum CodingKeys: CodingKey {
        case historyId, hasTool, name, msg, arguments
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        historyId = try container.decodeIfPresent(Int.self, forKey: .historyId)
        hasTool = try container.decodeIfPresent(Bool.self, forKey: .hasTool)
        name = try container.decodeIfPresent(FunctionName.self, forKey: .name)
        msg = try container.decodeIfPresent(String.self, forKey: .msg)
        arguments = try Self.decodeArguments(from: container, name: name)
    }
    
    func toDomainModel() -> FunctionModel {
        FunctionModel(
            historyId: historyId,
            hasTool: hasTool,
            name: name,
            msg: msg,
            arguments: arguments
        )
    }
}

private extension HistoryFunctionContentDTO {
    static func decodeArguments(
        from container: KeyedDecodingContainer<CodingKeys>,
        name: FunctionName?
    ) throws -> FunctionArguments? {
        guard let name else { return nil }
        
        switch name {
        case .queryArGroupByOrg, .queryArGroupByCustomer, .queryAccountGroupByAge:
            return .basic(try container.decode(BasicQueryModel.self, forKey: .arguments))
        case .querySalesGroupByOrgAndGoodsType, .querySalesGroupByMonth, .querySalesGroupByCustomer,
             .queryPurchaseGroupByOrg, .queryPurchaseGroupByMonth, .queryPurchaseGroupByCustomer:
            return .timeRange(try container.decode(TimeRangeQueryModel.self, forKey: .arguments))
        case .queryStockGroupByOrg, .queryStockGroupByWarehouse, .queryInventoryGroupByOrg,
             .queryInventoryGroupByWarehouse, .queryProcurementGroupByOrg, .queryProcurementGroupByCustomer:
            return .warehouse(try container.decode(WarehouseQueryModel.self, forKey: .arguments))
        case .queryAccountAgeGroupByOrg, .queryAccountAgeGroupByCustomer:
            return .accountAge(try container.decode(AccountAgeQueryModel.self, forKey: .arguments))
        case .queryPerformanceType:
            return .performanceType(try container.decode(PerformanceTypeQueryModel.self, forKey: .arguments))
        default:
            return nil
        }
    }
}
