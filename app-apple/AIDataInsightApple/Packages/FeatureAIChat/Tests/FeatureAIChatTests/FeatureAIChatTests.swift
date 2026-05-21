import Testing
import AppContracts
@testable import FeatureAIChat

@MainActor
@Test func chatStoreStartsNewChat() {
    let store = AIChatStore()
    store.appendUserMessage("hello")
    #expect(store.messages.count == 1)

    store.startNewChat()
    #expect(store.messages.isEmpty)
}

@MainActor
@Test func chatStoreLoadsTemplateQuestions() async {
    let store = AIChatStore(repository: PreviewAIChatRepository())

    await store.loadTemplate()

    #expect(store.state.templateQuestions.isEmpty == false)
}

@MainActor
@Test func chatStoreSendsMessageAndReceivesAssistantReply() async {
    let store = AIChatStore(repository: PreviewAIChatRepository())
    store.updateDraft("查询本月销售额")

    await store.sendCurrentMessage()

    #expect(store.state.messages.count == 2)
    #expect(store.state.messages.first?.role == .user)
    #expect(store.state.messages.last?.role == .assistant)
    #expect(store.state.messages.last?.contentKind == .chart)
    #expect(store.state.messages.last?.text == "根据您的查询，以下是分析结果:")
}

@MainActor
@Test func templateQuestionKeepsWelcomeAndDoesNotUseStreamFallback() async {
    let repository = FailingFunctionRepository()
    let store = AIChatStore(repository: repository)

    await store.sendTemplateQuestion("查询本月销售额")

    #expect(store.state.showsWelcome)
    #expect(store.state.messages.count == 2)
    #expect(store.state.messages.first?.role == .user)
    #expect(store.state.messages.last?.text == "这个问题目前无法回答。请尝试以不同的方式重新表述您的问题。")
    let streamCount = await repository.streamCount
    #expect(streamCount == 0)
}

@MainActor
@Test func loadingHistoryHidesWelcomeBubble() async {
    let repository = HistoryChartRepository(record: HistoryRecordContract(
        id: 123,
        name: "January sales",
        detailList: [
            HistoryDetailContract(id: 1001, historyId: 123, type: .question, contentType: .ai, content: "查看一月销售额"),
        ]
    ))
    let store = AIChatStore(repository: repository)

    await store.loadHistory(historyID: 123)

    #expect(store.state.showsWelcome == false)
}

@Test func chartPayloadMapsCommonSeries() {
    let detail = HistoryChartDetailContract(
        historyDetailId: 1,
        funcType: .querySalesGroupByMonth,
        chartCommonVoList: [
            ChartCommonItemContract(bizId: "1", name: "一月", value: 10),
        ]
    )

    let payload = ChartPayloadViewState(detail: detail, fallbackName: .querySalesGroupByMonth)

    #expect(payload.unit == .currency)
    #expect(payload.series.first?.xAxis == "一月")
    #expect(payload.series.first?.values == [10])
}

@MainActor
@Test func historyChartDetailMapsEmbeddedJSONToChartPayload() async {
    let chartJSON = #"{"funcType":"querySalesGroupByMonth","chartCommonVoList":[{"bizId":"2026-01","name":"2026-01","value":128800.5}],"accountAgeGroupVoList":null}"#
    let repository = HistoryChartRepository(record: HistoryRecordContract(
        id: 123,
        name: "January sales",
        detailList: [
            HistoryDetailContract(id: 1001, historyId: 123, type: .question, contentType: .ai, content: "查看一月销售额"),
            HistoryDetailContract(id: 1002, historyId: 123, type: .answer, contentType: .chart, content: chartJSON, isLike: "1"),
        ]
    ))
    let store = AIChatStore(repository: repository)

    await store.loadHistory(historyID: 123)

    let message = store.state.messages.last
    #expect(message?.contentKind == .chart)
    #expect(message?.text == "根据您的查询，以下是分析结果:")
    #expect(message?.chartPayload?.functionName == .querySalesGroupByMonth)
    #expect(message?.chartPayload?.series.first?.xAxis == "2026-01")
    #expect(message?.historyDetailID == 1002)
    #expect(message?.feedback == .liked)
}

private struct HistoryChartRepository: AIChatRepository {
    let record: HistoryRecordContract

    func loadTemplate() async throws -> TemplateQuestionSetContract {
        TemplateQuestionSetContract(questions: [])
    }

    func loadHistoryDetail(historyId: Int) async throws -> HistoryRecordContract {
        record
    }

    func sendFunctionMessage(text: String, historyId: Int?) async throws -> FunctionModelContract {
        FunctionModelContract(historyId: historyId, hasTool: false, name: nil, msg: nil, arguments: nil)
    }

    func loadChartData(name: FunctionNameContract, historyId: Int, arguments: FunctionArgumentsContract) async throws -> HistoryChartDetailContract {
        HistoryChartDetailContract(historyDetailId: nil, funcType: name, chartCommonVoList: nil)
    }

    func sendLikeFeedback(historyDetailId: Int, like: String) async throws {}

    func streamMessage(text: String) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            continuation.finish()
        }
    }
}

private actor FailingFunctionRepository: AIChatRepository {
    private(set) var streamCount = 0

    func loadTemplate() async throws -> TemplateQuestionSetContract {
        TemplateQuestionSetContract(questions: ["查询本月销售额"])
    }

    func loadHistoryDetail(historyId: Int) async throws -> HistoryRecordContract {
        HistoryRecordContract(id: historyId, name: nil, detailList: [])
    }

    func sendFunctionMessage(text: String, historyId: Int?) async throws -> FunctionModelContract {
        throw TestError.expected
    }

    func loadChartData(name: FunctionNameContract, historyId: Int, arguments: FunctionArgumentsContract) async throws -> HistoryChartDetailContract {
        throw TestError.expected
    }

    func sendLikeFeedback(historyDetailId: Int, like: String) async throws {}

    nonisolated func streamMessage(text: String) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                await incrementStreamCount()
                continuation.yield("stream fallback")
                continuation.finish()
            }
        }
    }

    private func incrementStreamCount() {
        streamCount += 1
    }
}

private enum TestError: Error {
    case expected
}
