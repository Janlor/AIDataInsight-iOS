import Foundation
import Testing
@testable import ModuleAI

@Suite(.serialized)
struct AIChatViewModelTests {
    @MainActor
    @Test
    func loadTemplate_failure_emitsNil() async {
        let viewModel = AIChatViewModel(
            repository: MockAIChatRepository(templateError: TestError.failed)
        )
        let recorder = OptionalQuestionsRecorder()

        viewModel.onTemplateLoaded = { questions in
            Task { await recorder.record(questions) }
        }

        await viewModel.loadTemplate()
        let result = await recorder.waitForValue()

        #expect(result == nil)
    }

    @MainActor
    @Test
    func getHistoryDetail_failure_emitsEmptyChats() async {
        let viewModel = AIChatViewModel(
            repository: MockAIChatRepository(historyDetailError: TestError.failed)
        )
        let recorder = ChatArrayRecorder()

        viewModel.onHistoryLoaded = { chats in
            Task { await recorder.record(chats) }
        }

        await viewModel.getHistoryDetail(1)
        let result = await recorder.waitForValue()

        #expect(result.isEmpty)
    }

    @MainActor
    @Test
    func sendFunctionMessage_businessFailure_emitsError() async {
        let viewModel = AIChatViewModel(
            repository: MockAIChatRepository(
                functionModel: FunctionModel(
                    historyId: nil,
                    hasTool: true,
                    name: .querySalesGroupByMonth,
                    msg: "bad response",
                    arguments: .performanceType(PerformanceTypeQueryModel(indexType: "sales"))
                )
            )
        )
        let recorder = FunctionResultRecorder()

        viewModel.onFunctionResult = { result in
            Task { await recorder.record(result) }
        }

        await viewModel.sendFunctionMessage("test")
        let result = await recorder.waitForValue()

        guard case let .error(message) = result else {
            Issue.record("Expected error result")
            return
        }
        #expect(message == "bad response")
    }

    @MainActor
    @Test
    func getChartData_businessFailure_emitsError() async {
        let viewModel = AIChatViewModel(
            repository: MockAIChatRepository(
                historyDetailModel: HistoryDetailModel(
                    funcType: nil,
                    chartCommonVoList: nil,
                    accountAgeGroupVoList: nil
                )
            )
        )
        let recorder = ChartResultRecorder()

        viewModel.onChartResult = { result in
            Task { await recorder.record(result) }
        }

        await viewModel.getChartData(
            name: .querySalesGroupByMonth,
            historyId: 1,
            arguments: .basic(
                BasicQueryModel(
                    orgId: 1,
                    customerName: nil,
                    orderType: nil,
                    operator: nil,
                    value: 1
                )
            )
        )
        let result = await recorder.waitForValue()

        guard case let .error(message) = result else {
            Issue.record("Expected error result")
            return
        }
        #expect(message != nil)
    }
}

private enum TestError: Error {
    case failed
}

private actor OptionalQuestionsRecorder {
    private var value: [String]??
    private var continuation: CheckedContinuation<[String]?, Never>?

    func record(_ value: [String]?) {
        self.value = value
        continuation?.resume(returning: value)
        continuation = nil
    }

    func waitForValue() async -> [String]? {
        if let value {
            return value
        }
        return await withCheckedContinuation { continuation in
            self.continuation = continuation
        }
    }
}

private actor ChatArrayRecorder {
    private var value: [AIChat]?
    private var continuation: CheckedContinuation<[AIChat], Never>?

    func record(_ value: [AIChat]) {
        self.value = value
        continuation?.resume(returning: value)
        continuation = nil
    }

    func waitForValue() async -> [AIChat] {
        if let value {
            return value
        }
        return await withCheckedContinuation { continuation in
            self.continuation = continuation
        }
    }
}

private actor FunctionResultRecorder {
    private var value: FunctionResult?
    private var continuation: CheckedContinuation<FunctionResult, Never>?

    func record(_ value: FunctionResult) {
        self.value = value
        continuation?.resume(returning: value)
        continuation = nil
    }

    func waitForValue() async -> FunctionResult {
        if let value {
            return value
        }
        return await withCheckedContinuation { continuation in
            self.continuation = continuation
        }
    }
}

private actor ChartResultRecorder {
    private var value: ChartResult?
    private var continuation: CheckedContinuation<ChartResult, Never>?

    func record(_ value: ChartResult) {
        self.value = value
        continuation?.resume(returning: value)
        continuation = nil
    }

    func waitForValue() async -> ChartResult {
        if let value {
            return value
        }
        return await withCheckedContinuation { continuation in
            self.continuation = continuation
        }
    }
}
