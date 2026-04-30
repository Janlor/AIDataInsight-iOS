//
//  AIChatViewModel.swift
//  ModuleAI
//
//  Created by Janlor on 4/24/26.
//

import Foundation
import BaseKit
import CommonViewModel

enum FunctionResult {
    case intent(text: String, type: AIChatIntentType)
    case error(String?)
    case timeout
}

enum ChartResult {
    case success(model: HistoryDetailModel, datas: [AIBarChartData])
    case error(String?)
    case timeout
}

final class AIChatViewModel: BaseViewModel {
    
    // MARK: - Output
    
    var onHistoryLoaded: (([AIChat]) -> Void)?
    var onTemplateLoaded: (([String]?) -> Void)?
    
    var onFunctionResult: ((FunctionResult) -> Void)?
    var onChartResult: ((ChartResult) -> Void)?
    var onStreamText: ((String) -> Void)?
    var onStreamCompleted: (() -> Void)?
    var onStreamFailed: ((String?) -> Void)?
    
    // MARK: - State
    
    private(set) var historyId: Int?
    
    public let appDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}

extension AIChatViewModel {
    
    func sendStreamMessage(_ text: String) {
        let urlString = "https://m1.apifoxmock.com/m1/3174267-1700689-default/stream"
        guard var components = URLComponents(string: urlString) else {
            onStreamFailed?("流式接口地址无效。")
            return
        }
        components.queryItems = [
            URLQueryItem(name: "question", value: text)
        ]
        
        guard let url = components.url else {
            onStreamFailed?("流式接口地址无效。")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        
        trackTask(
            CommonRequester.requestSSE(
                request,
                onEvent: { [weak self] chunk in
                    self?.onStreamText?(chunk)
                },
                completion: { [weak self] error in
                    guard let self else { return }
                    if let error {
                        self.onStreamFailed?(error.localizedDescription)
                    } else {
                        self.onStreamCompleted?()
                    }
                }
            ),
            for: .custom("ai-chat-stream")
        )
    }
    
    func getHistoryDetail(_ historyId: Int) {
        let target = HistoryApi.detail(historyId)
        
        CommonRequester.requestNet(target) { [weak self] (model: RecordModel?, error) in
            guard let self else { return }
            
            guard error == nil, let model,
                  let detailList = model.detailList else {
                return
            }
            
            DispatchQueue.global().async {
                let list = DetailModel.decodeDetailList(detailList)
                let chats = list.map { self.mapToChat($0) }
                
                DispatchQueue.main.async {
                    self.onHistoryLoaded?(chats)
                }
            }
        }
    }
    
    func loadTemplate() {
        let task = CommonRequester.requestNet(
            ChatApi.template
        ) { [weak self] (string: String?, _) in
            guard let self,
                  let string,
                  let data = string.data(using: .utf8),
                  let configure = try? appDecoder.decode(TemplateModel.self, from: data)
            else { return }
            
            self.onTemplateLoaded?(configure.questions)
        }
    }
    
    func sendLikeFeedback(historyDetailId: Int, like: String, completion: @escaping (Bool?) -> Void) {
        let target = HistoryApi.like(historyDetailId, like)
        
        CommonRequester.requestVoid(target) { success, _ in
            completion(success)
        }
    }
}

extension AIChatViewModel {
    
    func sendFunctionMessage(_ text: String) {
        let target = ChatApi.function(text, historyId)
        
        CommonRequester.requestNet(target) { [weak self] (model: FunctionModel?, error) in
            guard let self else { return }
            
            guard error == nil, let model else {
                self.onFunctionResult?(.timeout)
                return
            }
            
            guard let historyId = model.historyId else {
                self.onFunctionResult?(.error(model.msg))
                return
            }
            self.historyId = historyId
            
            guard let hasTool = model.hasTool, hasTool,
                  let name = model.name,
                  let arguments = model.arguments else {
                self.onFunctionResult?(.error(model.msg))
                return
            }
            
            /// 意图判断
            switch arguments {
            case let timeRange as TimeRangeQueryModel:
                if timeRange.startDate == nil {
                    self.onFunctionResult?(.intent(text: text, type: .time))
                    return
                }
                
            case _ as PerformanceTypeQueryModel:
                self.onFunctionResult?(.intent(text: text, type: .index))
                return
                
            default:
                break
            }
            
            self.getChartData(name: name, historyId: historyId, arguments: arguments)
        }
    }
}

extension AIChatViewModel {
    
    func getChartData(name: FunctionName, historyId: Int, arguments: Any) {
        guard let queryModel = arguments as? DictionaryConvertible else { return }
        
        let target = ChartApi.chart(name.rawValue, historyId, queryModel)
        
        CommonRequester.requestNet(target) { [weak self] (model: HistoryDetailModel?, error) in
            guard let self else { return }
            
            guard error == nil else {
                self.onChartResult?(.timeout)
                return
            }
            
            guard let model else {
                self.onChartResult?(.error(nil))
                return
            }
            
            let result = self.generateBarChartDatas(model)
            
            guard let datas = result.0 else {
                self.onChartResult?(.error(result.1 ?? "数据分析还在测试阶段，很快就能上线，敬请期待！"))
                return
            }
            
            self.onChartResult?(.success(model: model, datas: datas))
        }
    }
}

extension AIChatViewModel {
    
    func generateBarChartDatas(_ model: HistoryDetailModel) -> ([AIBarChartData]?, String?) {
        
        /// 通用柱状图
        if let list = model.chartCommonVoList, !list.isEmpty {
            let datas = list.map { item in
                let title = item.name ?? ""
                let value = item.value ?? 0
                let color = AIBarChartData.colorOptions.first ?? .systemBlue
                
                return AIBarChartData(
                    xAxis: title,
                    colors: [color],
                    labels: [title],
                    values: [value]
                )
            }
            return (datas, nil)
        }
        
        /// 账龄分布
        if let list = model.accountAgeGroupVoList, !list.isEmpty {
            
            /// 后端直接返回提示
            if let first = list.first,
               first.chartType == "2",
               let msg = first.msg {
                return (nil, msg)
            }
            
            let datas = list.map { item in
                let name = item.name ?? ""
                let values = item.valueList ?? []
                let labels = item.labelList ?? []
                
                let colors = values.indices.map {
                    AIBarChartData.colorOptions[$0 % AIBarChartData.colorOptions.count]
                }
                
                return AIBarChartData(
                    xAxis: name,
                    colors: colors,
                    labels: labels,
                    values: values
                )
            }
            
            return (datas, nil)
        }
        
        return (nil, nil)
    }
}

private extension AIChatViewModel {
    
    func mapToChat(_ model: DetailModel) -> AIChat {
        var isLike: Bool?
        if let like = model.isLike {
            isLike = like == "1"
        }
        
        if model.type == .question {
            return AIChat(text: model.content ?? "", type: .user)
        }
        
        if let chatModel = model.chatModel {
            let result = generateBarChartDatas(chatModel)
            
            if let datas = result.0 {
                return AIChat(
                    text: "根据您的查询，以下是分析结果:",
                    type: .chart,
                    isLike: isLike,
                    barChartDatas: datas,
                    historyDetailId: model.id,
                    funcType: chatModel.funcType
                )
            }
            
            return AIChat(
                text: result.1 ?? "数据分析还在测试阶段，很快就能上线，敬请期待！",
                type: .ai
            )
        }
        
        if let funcModel = model.funcModel {
            return AIChat(text: funcModel.msg ?? "", type: .ai)
        }
        
        return AIChat(
            text: model.content ?? "新版本上线啦，升级后我会变得更聪明，快来体验吧！",
            type: .ai
        )
    }
}
