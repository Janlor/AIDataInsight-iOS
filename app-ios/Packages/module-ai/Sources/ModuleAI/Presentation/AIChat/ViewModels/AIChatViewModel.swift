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
    private let loadTemplateUseCase: LoadTemplateUseCase
    private let loadHistoryDetailUseCase: LoadHistoryDetailUseCase
    private let sendFunctionMessageUseCase: SendFunctionMessageUseCase
    private let loadChartDataUseCase: LoadChartDataUseCase
    private let sendLikeFeedbackUseCase: SendLikeFeedbackUseCase
    private let streamAIResponseUseCase: StreamAIResponseUseCase
    private var streamTask: Task<Void, Never>?
    
    init(repository: AIChatRepository = DefaultAIChatRepository()) {
        self.loadTemplateUseCase = LoadTemplateUseCase(repository: repository)
        self.loadHistoryDetailUseCase = LoadHistoryDetailUseCase(repository: repository)
        self.sendFunctionMessageUseCase = SendFunctionMessageUseCase(repository: repository)
        self.loadChartDataUseCase = LoadChartDataUseCase(repository: repository)
        self.sendLikeFeedbackUseCase = SendLikeFeedbackUseCase(repository: repository)
        self.streamAIResponseUseCase = StreamAIResponseUseCase(repository: repository)
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
                for try await chunk in streamAIResponseUseCase.execute(text: text).stream {
                    onStreamText?(chunk)
                }
                guard Task.isCancelled == false else { return }
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
            let output = try await loadHistoryDetailUseCase.execute(historyId: historyId)
            onHistoryLoaded?(AIChatHistoryMapper.makeChats(from: output.messages))
        } catch {
            onHistoryLoaded?([])
        }
    }
    
    func loadTemplate() async {
        do {
            let output = try await loadTemplateUseCase.execute()
            onTemplateLoaded?(output.questions)
        } catch {
            onTemplateLoaded?(nil)
        }
    }
    
    func sendLikeFeedback(historyDetailId: Int, like: String) async -> Bool {
        do {
            try await sendLikeFeedbackUseCase.execute(historyDetailId: historyDetailId, like: like)
            return true
        } catch {
            return false
        }
    }
}

extension AIChatViewModel {
    
    func sendFunctionMessage(_ text: String) async {
        do {
            let result = try await sendFunctionMessageUseCase.execute(text: text, historyId: historyId)
            switch result {
            case .success(let output):
                switch output {
                case .intent(let text, let type):
                    onFunctionResult?(.intent(text: text, type: type))
                case .chartRequest(let name, let historyId, let arguments):
                    self.historyId = historyId
                    await getChartData(name: name, historyId: historyId, arguments: arguments)
                }
            case .failure(let failure):
                onFunctionResult?(.error(failure.message))
            }
        } catch {
            onFunctionResult?(.timeout)
        }
    }
}

extension AIChatViewModel {
    
    func getChartData(name: FunctionName, historyId: Int, arguments: FunctionArguments) async {
        do {
            let result = try await loadChartDataUseCase.execute(
                name: name,
                historyId: historyId,
                arguments: arguments
            )
            switch result {
            case .success(let output):
                onChartResult?(
                    .success(
                        funcType: output.payload.functionName,
                        historyDetailId: nil,
                        datas: AIChatChartBuilder.build(from: output.payload)
                    )
                )
            case .failure(let failure):
                onChartResult?(.error(failure.message))
            }
        } catch {
            onChartResult?(.timeout)
        }
    }
}
