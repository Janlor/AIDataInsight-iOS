//
//  AIChatViewModel.swift
//  ModuleAI
//
//  Created by Janlor on 4/24/26.
//

import Foundation
import CommonViewModel

enum FunctionResult {
    case intent(text: String, type: AIChatIntentType)
    case error(String?)
    case timeout
}

enum ChartResult {
    case success(funcType: FunctionName?, historyDetailId: Int?, datas: [AIBarChartData])
    case error(String?)
    case timeout
}

@MainActor
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
    private let repository: AIChatRepository
    private var streamTask: Task<Void, Never>?
    
    init(repository: AIChatRepository = DefaultAIChatRepository()) {
        self.repository = repository
        super.init()
    }
    
    deinit {
        streamTask?.cancel()
    }
}

extension AIChatViewModel {
    func resetConversation() {
        historyId = nil
        cancelStream()
    }
    
    func sendStreamMessage(_ text: String) {
        cancelStream()
        streamTask = Task { [weak self] in
            guard let self else { return }
            
            do {
                for try await chunk in repository.streamMessage(text) {
                    onStreamText?(chunk)
                }
                onStreamCompleted?()
            } catch is CancellationError {
                return
            } catch {
                onStreamFailed?(error.localizedDescription)
            }
        }
    }
    
    func cancelStream() {
        streamTask?.cancel()
        streamTask = nil
    }
    
    func getHistoryDetail(_ historyId: Int) async {
        do {
            self.historyId = historyId
            let model = try await repository.loadHistoryDetail(historyId)
            let chats = AIChatHistoryMapper.makeChats(from: model.detailList ?? [])
            onHistoryLoaded?(chats)
        } catch {
            onHistoryLoaded?([])
        }
    }
    
    func loadTemplate() async {
        do {
            let configure = try await repository.loadTemplate()
            onTemplateLoaded?(configure.questions)
        } catch {
            onTemplateLoaded?(nil)
        }
    }
    
    func sendLikeFeedback(historyDetailId: Int, like: String) async -> Bool {
        do {
            try await repository.sendLikeFeedback(historyDetailId: historyDetailId, like: like)
            return true
        } catch {
            return false
        }
    }
}

extension AIChatViewModel {
    
    func sendFunctionMessage(_ text: String) async {
        do {
            let model = try await repository.sendFunctionMessage(text, historyId: historyId)
            
            guard let historyId = model.historyId else {
                onFunctionResult?(.error(model.msg))
                return
            }
            self.historyId = historyId
            
            guard let hasTool = model.hasTool, hasTool,
                  let name = model.name,
                  let arguments = model.arguments else {
                onFunctionResult?(.error(model.msg))
                return
            }
            
            if let intent = AIChatIntentResolver.resolve(text: text, arguments: arguments) {
                onFunctionResult?(intent)
                return
            }
            
            await getChartData(name: name, historyId: historyId, arguments: arguments)
        } catch {
            onFunctionResult?(.timeout)
        }
    }
}

extension AIChatViewModel {
    
    func getChartData(name: FunctionName, historyId: Int, arguments: FunctionArguments) async {
        do {
            let model = try await repository.loadChartData(name: name, historyId: historyId, arguments: arguments)
            let result = AIChatChartBuilder.build(from: model)
            
            guard let datas = result.0 else {
                onChartResult?(.error(result.1 ?? "数据分析还在测试阶段，很快就能上线，敬请期待！"))
                return
            }
            
            onChartResult?(.success(funcType: model.funcType, historyDetailId: nil, datas: datas))
        } catch {
            onChartResult?(.timeout)
        }
    }
}
