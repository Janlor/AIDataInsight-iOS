import AppContracts
import AppCore
import AppNetworking
import Foundation
import Observation
import SwiftUI

public enum AIChatIntentType: String, Equatable, Sendable {
    case time
    case index
}

public enum ChatMessageContentKind: Equatable, Sendable {
    case text
    case chart
    case intent
    case welcome
}

public enum FeedbackState: Equatable, Sendable {
    case liked
    case disliked
    case none
    case unknown
}

public enum ChartUnit: Equatable, Sendable {
    case currency
    case ton
}

public struct ChartSeriesViewState: Identifiable, Equatable, Sendable {
    public let id: String
    public let xAxis: String
    public let labels: [String]
    public let values: [Double]

    public init(id: String = UUID().uuidString, xAxis: String, labels: [String], values: [Double]) {
        self.id = id
        self.xAxis = xAxis
        self.labels = labels
        self.values = values
    }
}

public struct ChartPayloadViewState: Equatable, Sendable {
    public let functionName: FunctionNameContract?
    public let unit: ChartUnit
    public let series: [ChartSeriesViewState]
    public let emptyMessage: String?

    public init(functionName: FunctionNameContract?, unit: ChartUnit, series: [ChartSeriesViewState], emptyMessage: String? = nil) {
        self.functionName = functionName
        self.unit = unit
        self.series = series
        self.emptyMessage = emptyMessage
    }

    public init(detail: HistoryChartDetailContract, fallbackName: FunctionNameContract) {
        if let first = detail.accountAgeGroupVoList?.first, first.chartType == "2", let msg = first.msg {
            self.init(functionName: detail.funcType ?? fallbackName, unit: .currency, series: [], emptyMessage: msg)
            return
        }

        let accountAgeSeries = (detail.accountAgeGroupVoList ?? []).map {
            ChartSeriesViewState(xAxis: $0.name ?? "", labels: $0.labelList ?? [], values: $0.valueList ?? [])
        }
        let commonSeries = (detail.chartCommonVoList ?? []).map {
            ChartSeriesViewState(xAxis: $0.name ?? "", labels: [$0.name ?? ""], values: [$0.value ?? 0])
        }
        let functionName = detail.funcType ?? fallbackName
        self.init(
            functionName: functionName,
            unit: functionName.usesTon ? .ton : .currency,
            series: accountAgeSeries + commonSeries
        )
    }
}

public struct ChatMessageViewState: Identifiable, Equatable, Sendable {
    public enum Role: Equatable, Sendable {
        case user
        case assistant
    }

    public let id: String
    public let role: Role
    public var contentKind: ChatMessageContentKind
    public var text: String
    public var intentType: AIChatIntentType?
    public var chartPayload: ChartPayloadViewState?
    public var feedback: FeedbackState
    public var historyDetailID: Int?
    public var functionName: FunctionNameContract?

    public init(
        id: String = UUID().uuidString,
        role: Role,
        contentKind: ChatMessageContentKind = .text,
        text: String,
        intentType: AIChatIntentType? = nil,
        chartPayload: ChartPayloadViewState? = nil,
        feedback: FeedbackState = .none,
        historyDetailID: Int? = nil,
        functionName: FunctionNameContract? = nil
    ) {
        self.id = id
        self.role = role
        self.contentKind = contentKind
        self.text = text
        self.intentType = intentType
        self.chartPayload = chartPayload
        self.feedback = feedback
        self.historyDetailID = historyDetailID
        self.functionName = functionName
    }
}

public struct AIChatViewState: Equatable, Sendable {
    public var messages: [ChatMessageViewState]
    public var draft: String
    public var templateQuestions: [String]
    public var activeHistoryID: Int?
    public var isLoadingTemplate: Bool
    public var isSending: Bool
    public var errorMessage: String?

    public init(
        messages: [ChatMessageViewState] = [],
        draft: String = "",
        templateQuestions: [String] = [],
        activeHistoryID: Int? = nil,
        isLoadingTemplate: Bool = false,
        isSending: Bool = false,
        errorMessage: String? = nil
    ) {
        self.messages = messages
        self.draft = draft
        self.templateQuestions = templateQuestions
        self.activeHistoryID = activeHistoryID
        self.isLoadingTemplate = isLoadingTemplate
        self.isSending = isSending
        self.errorMessage = errorMessage
    }
}

public protocol AIChatRepository: Sendable {
    func loadTemplate() async throws -> TemplateQuestionSetContract
    func loadHistoryDetail(historyId: Int) async throws -> HistoryRecordContract
    func sendFunctionMessage(text: String, historyId: Int?) async throws -> FunctionModelContract
    func loadChartData(name: FunctionNameContract, historyId: Int, arguments: FunctionArgumentsContract) async throws -> HistoryChartDetailContract
    func sendLikeFeedback(historyDetailId: Int, like: String) async throws
    func streamMessage(text: String) -> AsyncThrowingStream<String, Error>
}

public struct RemoteAIChatRepository: AIChatRepository {
    private let client: HTTPClient
    private let streamer: SSEStreaming?

    public init(client: HTTPClient, streamer: SSEStreaming? = nil) {
        self.client = client
        self.streamer = streamer
    }

    public func loadTemplate() async throws -> TemplateQuestionSetContract {
        let envelope = try await client.send(HTTPRequest(path: "/chat/template"), as: TemplateQuestionPayload.self)
        guard let payload = envelope.data else {
            throw AppError(kind: .dataFormat, traceID: envelope.trace, transactionID: envelope.tid)
        }
        return payload.value
    }

    public func loadHistoryDetail(historyId: Int) async throws -> HistoryRecordContract {
        let envelope = try await client.send(
            HTTPRequest(path: "/history/detail", queryItems: [HTTPQueryItem(name: "historyId", value: String(historyId))]),
            as: HistoryRecordContract.self
        )
        guard let record = envelope.data else {
            throw AppError(kind: .dataFormat, traceID: envelope.trace, transactionID: envelope.tid)
        }
        return record
    }

    public func sendFunctionMessage(text: String, historyId: Int?) async throws -> FunctionModelContract {
        var queryItems = [HTTPQueryItem(name: "question", value: text)]
        if let historyId {
            queryItems.append(HTTPQueryItem(name: "historyId", value: String(historyId)))
        }
        let envelope = try await client.send(HTTPRequest(path: "/chat/function", queryItems: queryItems), as: FunctionModelContract.self)
        guard let model = envelope.data else {
            throw AppError(kind: .dataFormat, traceID: envelope.trace, transactionID: envelope.tid)
        }
        return model
    }

    public func loadChartData(name: FunctionNameContract, historyId: Int, arguments: FunctionArgumentsContract) async throws -> HistoryChartDetailContract {
        let envelope = try await client.send(
            HTTPRequest(
                path: "/chart/\(name.rawValue)",
                queryItems: [HTTPQueryItem(name: "historyId", value: String(historyId))] + arguments.queryItems
            ),
            as: HistoryChartDetailContract.self
        )
        guard let detail = envelope.data else {
            throw AppError(kind: .dataFormat, traceID: envelope.trace, transactionID: envelope.tid)
        }
        return detail
    }

    public func sendLikeFeedback(historyDetailId: Int, like: String) async throws {
        let body = try JSONEncoder().encode(LikeHistoryDetailRequestContract(historyDetailId: historyDetailId, like: like))
        _ = try await client.send(
            HTTPRequest(path: "/history/like", method: .post, headers: ["Content-Type": "application/json"], body: body),
            as: EmptyContract.self
        )
    }

    public func streamMessage(text: String) -> AsyncThrowingStream<String, Error> {
        guard let streamer else {
            return AsyncThrowingStream { continuation in
                continuation.finish()
            }
        }
        return AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    for try await event in streamer.stream(HTTPRequest(path: "/stream", queryItems: [HTTPQueryItem(name: "question", value: text)])) {
                        continuation.yield(event.data)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}

@MainActor
@Observable
public final class AIChatStore {
    public private(set) var state: AIChatViewState
    private let repository: AIChatRepository
    private var streamTask: Task<Void, Never>?

    public init(state: AIChatViewState = AIChatViewState(), repository: AIChatRepository = PreviewAIChatRepository()) {
        self.state = state
        self.repository = repository
    }

    public var messages: [ChatMessageViewState] {
        state.messages
    }

    public func loadTemplate() async {
        guard state.templateQuestions.isEmpty else {
            return
        }
        state.isLoadingTemplate = true
        state.errorMessage = nil
        do {
            state.templateQuestions = try await repository.loadTemplate().questions
        } catch {
            state.errorMessage = "推荐问题加载失败"
        }
        state.isLoadingTemplate = false
    }

    public func startNewChat() {
        streamTask?.cancel()
        state.messages.removeAll()
        state.draft = ""
        state.activeHistoryID = nil
        state.errorMessage = nil
    }

    public func updateDraft(_ draft: String) {
        state.draft = draft
        state.errorMessage = nil
    }

    public func appendUserMessage(_ text: String) {
        state.messages.append(ChatMessageViewState(role: .user, text: text))
    }

    public func sendTemplateQuestion(_ text: String) async {
        state.draft = text
        await sendCurrentMessage()
    }

    public func sendCurrentMessage() async {
        let text = state.draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard text.isEmpty == false, state.isSending == false else {
            return
        }

        appendUserMessage(text)
        state.draft = ""
        state.isSending = true
        state.errorMessage = nil

        do {
            let function = try await repository.sendFunctionMessage(text: text, historyId: state.activeHistoryID)
            state.activeHistoryID = function.historyId ?? state.activeHistoryID
            try await handle(function: function)
        } catch {
            await streamFallbackResponse(for: text)
        }

        state.isSending = false
    }

    public func loadHistory(historyID: Int) async {
        state.errorMessage = nil
        do {
            let record = try await repository.loadHistoryDetail(historyId: historyID)
            state.activeHistoryID = record.id
            state.messages = (record.detailList ?? []).map(ChatMessageViewState.init(contract:))
        } catch {
            state.errorMessage = "历史会话加载失败"
        }
    }

    public func sendFeedback(messageID: String, like: String) async {
        guard let index = state.messages.firstIndex(where: { $0.id == messageID }),
              let historyDetailID = state.messages[index].historyDetailID
        else {
            return
        }
        do {
            try await repository.sendLikeFeedback(historyDetailId: historyDetailID, like: like)
            state.messages[index].feedback = like == "1" ? .liked : .disliked
        } catch {
            state.errorMessage = "反馈提交失败"
        }
    }

    private func handle(function: FunctionModelContract) async throws {
        guard let historyID = function.historyId else {
            throw AppError(kind: .dataFormat)
        }
        guard function.hasTool == true, let name = function.name, let arguments = function.arguments else {
            appendAssistantText(function.msg ?? "暂时无法完成该分析")
            return
        }

        if case .timeRange(let value) = arguments, value.startDate == nil {
            appendAssistantIntent(text: function.msg ?? "请选择时间范围", intentType: .time)
            return
        }

        if case .performanceType = arguments {
            appendAssistantIntent(text: function.msg ?? "请选择指标类型", intentType: .index)
            return
        }

        let chartDetail = try await repository.loadChartData(name: name, historyId: historyID, arguments: arguments)
        let payload = ChartPayloadViewState(detail: chartDetail, fallbackName: name)
        state.messages.append(ChatMessageViewState(
            role: .assistant,
            contentKind: .chart,
            text: payload.emptyMessage ?? function.msg ?? "已生成分析图表",
            chartPayload: payload,
            feedback: .none,
            historyDetailID: chartDetail.historyDetailId,
            functionName: payload.functionName
        ))
    }

    private func streamFallbackResponse(for text: String) async {
        let assistantID = UUID().uuidString
        state.messages.append(ChatMessageViewState(id: assistantID, role: .assistant, text: ""))
        do {
            for try await chunk in repository.streamMessage(text: text) {
                if let index = state.messages.firstIndex(where: { $0.id == assistantID }) {
                    state.messages[index].text += chunk
                }
            }
            if let index = state.messages.firstIndex(where: { $0.id == assistantID }), state.messages[index].text.isEmpty {
                state.messages[index].text = "暂时无法完成该分析"
            }
        } catch {
            if let index = state.messages.firstIndex(where: { $0.id == assistantID }) {
                state.messages[index].text = "暂时无法完成该分析"
            }
        }
    }

    private func appendAssistantText(_ text: String) {
        state.messages.append(ChatMessageViewState(role: .assistant, text: text))
    }

    private func appendAssistantIntent(text: String, intentType: AIChatIntentType) {
        state.messages.append(ChatMessageViewState(role: .assistant, contentKind: .intent, text: text, intentType: intentType))
    }
}

public struct AIChatScreen: View {
    @Bindable private var store: AIChatStore

    public init(store: AIChatStore) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            content
            Divider()
            composer
        }
        .navigationTitle("AI数据分析助手")
        .task {
            await store.loadTemplate()
        }
    }

    @ViewBuilder
    private var content: some View {
        if store.state.messages.isEmpty {
            VStack(spacing: 18) {
                Text("今天想分析什么？")
                    .font(.title.bold())
                    .accessibilityIdentifier("ai-chat-empty-title")

                if store.state.isLoadingTemplate {
                    ProgressView()
                } else {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 180), spacing: 12)], spacing: 12) {
                        ForEach(store.state.templateQuestions, id: \.self) { question in
                            Button {
                                Task {
                                    await store.sendTemplateQuestion(question)
                                }
                            } label: {
                                Text(question)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(12)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .frame(maxWidth: 720)
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List(store.state.messages) { message in
                messageView(message)
                    .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
        }
    }

    private var composer: some View {
        HStack(spacing: 12) {
            TextField("输入你的数据分析问题", text: Binding(
                get: { store.state.draft },
                set: { store.updateDraft($0) }
            ), axis: .vertical)
            .textFieldStyle(.roundedBorder)
            Button("发送", systemImage: "paperplane.fill") {
                Task {
                    await store.sendCurrentMessage()
                }
            }
            .disabled(store.state.draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || store.state.isSending)
        }
        .padding(16)
    }

    @ViewBuilder
    private func messageView(_ message: ChatMessageViewState) -> some View {
        VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 8) {
            Text(message.text)
                .padding(12)
                .background(message.role == .user ? Color.accentColor.opacity(0.16) : Color.secondary.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            if let chartPayload = message.chartPayload {
                chartSummary(chartPayload)
            }
        }
        .frame(maxWidth: .infinity, alignment: message.role == .user ? .trailing : .leading)
    }

    private func chartSummary(_ payload: ChartPayloadViewState) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(payload.functionName?.rawValue ?? "Chart")
                .font(.headline)
            ForEach(payload.series) { series in
                HStack {
                    Text(series.xAxis)
                    Spacer()
                    Text(series.values.map { $0.formatted() }.joined(separator: ", "))
                        .foregroundStyle(.secondary)
                }
                .font(.footnote)
            }
        }
        .padding(12)
        .background(Color.secondary.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct TemplateQuestionPayload: Decodable, Sendable {
    let value: TemplateQuestionSetContract

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(TemplateQuestionSetContract.self) {
            self.value = value
            return
        }
        let string = try container.decode(String.self)
        guard let data = string.data(using: .utf8) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid template JSON string.")
        }
        value = try JSONDecoder().decode(TemplateQuestionSetContract.self, from: data)
    }
}

private extension ChatMessageViewState {
    init(contract: HistoryDetailContract) {
        let role: Role = contract.type == .question ? .user : .assistant
        let contentKind: ChatMessageContentKind = contract.contentType == .chart ? .chart : .text
        self.init(
            id: contract.id.map(String.init) ?? UUID().uuidString,
            role: role,
            contentKind: contentKind,
            text: contract.content ?? "",
            historyDetailID: contract.id
        )
    }
}

private extension FunctionNameContract {
    var usesTon: Bool {
        self == .queryStockGroupByOrg || self == .queryStockGroupByWarehouse
    }
}

private extension FunctionArgumentsContract {
    var queryItems: [HTTPQueryItem] {
        switch self {
        case .basic(let value):
            value.queryItems
        case .timeRange(let value):
            value.queryItems
        case .warehouse(let value):
            value.queryItems
        case .accountAge(let value):
            value.queryItems
        case .performanceType(let value):
            value.queryItems
        }
    }
}

private extension BasicQueryContract {
    var queryItems: [HTTPQueryItem] {
        [
            HTTPQueryItem(name: "orgId", value: orgId.map(String.init)),
            HTTPQueryItem(name: "customerName", value: customerName),
            HTTPQueryItem(name: "orderType", value: orderType),
            HTTPQueryItem(name: "operator", value: `operator`),
            HTTPQueryItem(name: "value", value: value.map { String($0) }),
        ].compactValueItems
    }
}

private extension TimeRangeQueryContract {
    var queryItems: [HTTPQueryItem] {
        [
            HTTPQueryItem(name: "startDate", value: startDate),
            HTTPQueryItem(name: "endDate", value: endDate),
            HTTPQueryItem(name: "orgId", value: orgId.map(String.init)),
            HTTPQueryItem(name: "customerName", value: customerName),
            HTTPQueryItem(name: "goodsType", value: goodsType.map(String.init)),
            HTTPQueryItem(name: "orderType", value: orderType),
            HTTPQueryItem(name: "operator", value: `operator`),
            HTTPQueryItem(name: "value", value: value.map { String($0) }),
        ].compactValueItems
    }
}

private extension WarehouseQueryContract {
    var queryItems: [HTTPQueryItem] {
        [
            HTTPQueryItem(name: "orgId", value: orgId.map(String.init)),
            HTTPQueryItem(name: "warehouseName", value: warehouseName),
            HTTPQueryItem(name: "goodsType", value: goodsType.map(String.init)),
            HTTPQueryItem(name: "orderType", value: orderType),
            HTTPQueryItem(name: "operator", value: `operator`),
            HTTPQueryItem(name: "value", value: value.map { String($0) }),
        ].compactValueItems
    }
}

private extension AccountAgeQueryContract {
    var queryItems: [HTTPQueryItem] {
        [
            HTTPQueryItem(name: "orgId", value: orgId.map(String.init)),
            HTTPQueryItem(name: "customerName", value: customerName),
            HTTPQueryItem(name: "orderType", value: orderType),
        ].compactValueItems + (valueArray ?? []).map { HTTPQueryItem(name: "valueArray", value: $0) }
    }
}

private extension PerformanceTypeQueryContract {
    var queryItems: [HTTPQueryItem] {
        [HTTPQueryItem(name: "indexType", value: indexType)].compactValueItems
    }
}

private extension Array where Element == HTTPQueryItem {
    var compactValueItems: [HTTPQueryItem] {
        filter { $0.value != nil }
    }
}

public struct PreviewAIChatRepository: AIChatRepository {
    public init() {}

    public func loadTemplate() async throws -> TemplateQuestionSetContract {
        TemplateQuestionSetContract(questions: ["查询本月销售额", "按客户分析应收账款", "查看库存吨数"])
    }

    public func loadHistoryDetail(historyId: Int) async throws -> HistoryRecordContract {
        HistoryRecordContract(id: historyId, name: "Preview", detailList: [])
    }

    public func sendFunctionMessage(text: String, historyId: Int?) async throws -> FunctionModelContract {
        FunctionModelContract(historyId: historyId ?? 1, hasTool: false, name: nil, msg: "这是预览环境的回复：\(text)", arguments: nil)
    }

    public func loadChartData(name: FunctionNameContract, historyId: Int, arguments: FunctionArgumentsContract) async throws -> HistoryChartDetailContract {
        HistoryChartDetailContract(historyDetailId: 1, funcType: name, chartCommonVoList: [])
    }

    public func sendLikeFeedback(historyDetailId: Int, like: String) async throws {}

    public func streamMessage(text: String) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            continuation.yield("这是预览环境的流式回复：\(text)")
            continuation.finish()
        }
    }
}
