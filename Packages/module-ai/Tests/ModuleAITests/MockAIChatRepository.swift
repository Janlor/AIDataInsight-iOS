import Foundation
@testable import ModuleAI

struct MockAIChatRepository: AIChatRepository {
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
        template
    }

    func loadHistoryDetail(_ historyId: Int) async throws -> RecordModel {
        record
    }

    func sendFunctionMessage(_ text: String, historyId: Int?) async throws -> FunctionModel {
        functionModel
    }

    func loadChartData(name: FunctionName, historyId: Int, arguments: FunctionArguments) async throws -> HistoryDetailModel {
        historyDetailModel
    }

    func sendLikeFeedback(historyDetailId: Int, like: String) async throws {}

    func streamMessage(_ text: String) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            continuation.finish()
        }
    }
}
