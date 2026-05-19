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
