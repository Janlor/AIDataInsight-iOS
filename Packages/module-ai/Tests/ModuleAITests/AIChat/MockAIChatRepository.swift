import Foundation
@testable import ModuleAI

struct MockAIChatRepository: AIChatRepository {
    var templateError: Error?
    var historyDetailError: Error?
    var sendFunctionMessageError: Error?
    var loadChartDataError: Error?
    var sendLikeFeedbackError: Error?
    var template: TemplateModel = TemplateModel(questions: [])
    var record: RecordModel = RecordModel(
        id: nil,
        name: nil,
        createId: nil,
        updateId: nil,
        createName: nil,
        updateName: nil,
        createTime: nil,
        updateTime: nil,
        detailList: []
    )
    var functionModel: FunctionModel = FunctionModel(
        historyId: nil,
        hasTool: nil,
        name: nil,
        msg: nil,
        arguments: nil
    )
    var historyDetailModel: HistoryDetailModel = HistoryDetailModel(
        funcType: nil,
        chartCommonVoList: nil,
        accountAgeGroupVoList: nil
    )

    func loadTemplate() async throws -> TemplateModel {
        if let templateError {
            throw templateError
        }
        template
    }

    func loadHistoryDetail(_ historyId: Int) async throws -> RecordModel {
        if let historyDetailError {
            throw historyDetailError
        }
        record
    }

    func sendFunctionMessage(_ text: String, historyId: Int?) async throws -> FunctionModel {
        if let sendFunctionMessageError {
            throw sendFunctionMessageError
        }
        functionModel
    }

    func loadChartData(name: FunctionName, historyId: Int, arguments: FunctionArguments) async throws -> HistoryDetailModel {
        if let loadChartDataError {
            throw loadChartDataError
        }
        historyDetailModel
    }

    func sendLikeFeedback(historyDetailId: Int, like: String) async throws {
        if let sendLikeFeedbackError {
            throw sendLikeFeedbackError
        }
    }

    func streamMessage(_ text: String) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            continuation.finish()
        }
    }
}
