import AppContracts
import AppCore
import AppDesignSystem
import AppNetworking
import Foundation
import Observation
import SwiftUI
#if os(macOS)
import AppKit
#endif

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
    private let bottomAnchorID = "chat-bottom-anchor"

    public init(store: AIChatStore) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            content
            composer
        }
        .background(Color(nsColorCompatibleLight: "#F7F8FA", dark: "#0B1020"))
        .navigationTitle("AI数据分析助手")
        .accessibilityIdentifier("ai-chat-screen")
#if os(macOS)
        .navigationSubtitle(store.state.activeHistoryID == nil ? "New Chat" : "History")
#endif
        .task {
            await store.loadTemplate()
        }
    }

    @ViewBuilder
    private var content: some View {
        if store.state.messages.isEmpty {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("今天想分析什么？")
                            .font(.system(size: 30, weight: .semibold))
                            .accessibilityIdentifier("ai-chat-empty-title")
                        Text("选择一个推荐问题，或者直接输入经营数据分析需求。")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    if store.state.isLoadingTemplate {
                        ProgressView()
                    } else {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 220), spacing: 12)], spacing: 12) {
                            ForEach(store.state.templateQuestions, id: \.self) { question in
                                Button {
                                    Task {
                                        await store.sendTemplateQuestion(question)
                                    }
                                } label: {
                                    HStack(alignment: .top, spacing: 10) {
                                        Image(systemName: "sparkles")
                                            .foregroundStyle(.blue)
                                        Text(question)
                                            .multilineTextAlignment(.leading)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .padding(14)
                                    .frame(minHeight: 74, alignment: .topLeading)
                                    .background(Color(nsColorCompatibleLight: "#FFFFFF", dark: "#151D30"), in: RoundedRectangle(cornerRadius: 8))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.secondary.opacity(0.18))
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(.horizontal, 32)
                .padding(.top, 72)
                .frame(maxWidth: 860)
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 18) {
                        ForEach(store.state.messages) { message in
                            messageView(message)
                                .id(message.id)
                        }
                        if store.state.isSending {
                            HStack {
                                ProgressView()
                                    .controlSize(.small)
                                Text("分析中...")
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        Color.clear
                            .frame(height: 1)
                            .id(bottomAnchorID)
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 24)
                    .frame(maxWidth: 900)
                    .frame(maxWidth: .infinity)
                }
                .onAppear {
                    scrollToBottom(proxy)
                }
                .onChange(of: store.state.messages.count) { _, _ in
                    scrollToBottom(proxy)
                }
                .onChange(of: store.state.messages.last?.text) { _, _ in
                    scrollToBottom(proxy)
                }
                .onChange(of: store.state.isSending) { _, _ in
                    scrollToBottom(proxy)
                }
            }
        }
    }

    private var composer: some View {
        VStack(spacing: 8) {
            if let errorMessage = store.state.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .frame(maxWidth: 860, alignment: .leading)
            }

            HStack(alignment: .bottom, spacing: 10) {
                TextField("输入你的数据分析问题", text: Binding(
                    get: { store.state.draft },
                    set: { store.updateDraft($0) }
                ), axis: .vertical)
                .lineLimit(1...5)
                .textFieldStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .accessibilityIdentifier("chat-composer-input")

                Button {
                    Task {
                        await store.sendCurrentMessage()
                    }
                } label: {
                    Image(systemName: "paperplane.fill")
                        .frame(width: 30, height: 30)
                }
                .help("发送")
                .disabled(store.state.draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || store.state.isSending)
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("chat-send-button")
            }
            .padding(6)
            .frame(maxWidth: 860)
            .background(Color(nsColorCompatibleLight: "#FFFFFF", dark: "#151D30"), in: RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.secondary.opacity(0.20))
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 18)
        .background(.bar)
    }

    @ViewBuilder
    private func messageView(_ message: ChatMessageViewState) -> some View {
        HStack(alignment: .top, spacing: 12) {
            if message.role == .assistant {
                avatar(systemName: "sparkles", color: .blue)
            } else {
                Spacer(minLength: 80)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text(message.text)
                    .foregroundStyle(.primary)
                    .textSelection(.enabled)

                if let chartPayload = message.chartPayload {
                    chartSummary(chartPayload)
                }
            }
            .padding(14)
            .background(message.role == .user ? Color.blue.opacity(0.12) : Color(nsColorCompatibleLight: "#FFFFFF", dark: "#151D30"), in: RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.secondary.opacity(message.role == .user ? 0.05 : 0.16))
            }
            .frame(maxWidth: 680, alignment: message.role == .user ? .trailing : .leading)

            if message.role == .user {
                avatar(systemName: "person.fill", color: .secondary)
            } else {
                Spacer(minLength: 80)
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityIdentifier("chat-message-\(message.id)")
    }

    private func chartSummary(_ payload: ChartPayloadViewState) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(payload.functionName?.rawValue ?? "Chart")
                    .font(.headline)
                Spacer()
                Text(payload.unit == .ton ? "吨" : "元")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            ForEach(payload.series) { series in
                let maxValue = payload.series.flatMap(\.values).max() ?? 1
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(series.xAxis)
                        Spacer()
                        Text(series.values.map { $0.formatted() }.joined(separator: ", "))
                            .foregroundStyle(.secondary)
                    }
                    GeometryReader { proxy in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(.blue.opacity(0.20))
                            .overlay(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(.blue)
                                    .frame(width: proxy.size.width * max(0.04, (series.values.first ?? 0) / maxValue))
                            }
                    }
                    .frame(height: 8)
                }
                .font(.footnote)
            }
        }
        .padding(12)
        .background(Color.blue.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))
    }

    private func avatar(systemName: String, color: Color) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(color)
            .frame(width: 28, height: 28)
            .background(color.opacity(0.12), in: Circle())
    }

    private func scrollToBottom(_ proxy: ScrollViewProxy) {
        Task { @MainActor in
            withAnimation(.snappy(duration: 0.22)) {
                proxy.scrollTo(bottomAnchorID, anchor: .bottom)
            }
        }
    }
}

private extension Color {
    init(nsColorCompatibleLight lightHex: String, dark darkHex: String) {
#if os(macOS)
        self.init(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(Color(hex: darkHex))
                : NSColor(Color(hex: lightHex))
        })
#else
        self.init(hex: lightHex)
#endif
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
        TemplateQuestionSetContract(questions: [
            "查询本月销售额趋势",
            "按客户分析应收账款",
            "查看各组织库存吨数",
            "采购金额按月份对比",
        ])
    }

    public func loadHistoryDetail(historyId: Int) async throws -> HistoryRecordContract {
        let item = PreviewHistoryItem.item(for: historyId)
        return HistoryRecordContract(
            id: historyId,
            name: item.title,
            updateTime: ISO8601DateFormatter().string(from: .now),
            detailList: [
                HistoryDetailContract(id: historyId * 10 + 1, historyId: historyId, type: .question, contentType: .ai, content: item.question),
                HistoryDetailContract(id: historyId * 10 + 2, historyId: historyId, type: .answer, contentType: .ai, content: item.answer),
            ]
        )
    }

    public func sendFunctionMessage(text: String, historyId: Int?) async throws -> FunctionModelContract {
        if text.contains("库存") {
            return FunctionModelContract(
                historyId: historyId ?? 101,
                hasTool: true,
                name: .queryStockGroupByOrg,
                msg: "已按组织生成库存吨数对比。",
                arguments: .basic(BasicQueryContract(orgId: nil, customerName: nil, orderType: nil, operator: nil, value: nil))
            )
        }

        if text.contains("应收") {
            return FunctionModelContract(
                historyId: historyId ?? 102,
                hasTool: true,
                name: .queryArGroupByCustomer,
                msg: "已按客户生成应收账款分析。",
                arguments: .basic(BasicQueryContract(orgId: nil, customerName: nil, orderType: nil, operator: nil, value: nil))
            )
        }

        if text.contains("采购") {
            return FunctionModelContract(
                historyId: historyId ?? 103,
                hasTool: true,
                name: .queryPurchaseGroupByMonth,
                msg: "已生成采购金额月度对比。",
                arguments: .timeRange(TimeRangeQueryContract(startDate: "2026-05-01", endDate: "2026-05-31", orgId: nil, customerName: nil, goodsType: nil, orderType: nil, operator: nil, value: nil))
            )
        }

        return FunctionModelContract(
            historyId: historyId ?? 100,
            hasTool: true,
            name: .querySalesGroupByMonth,
            msg: "已生成本月销售额趋势。",
            arguments: .timeRange(TimeRangeQueryContract(startDate: "2026-05-01", endDate: "2026-05-31", orgId: nil, customerName: nil, goodsType: nil, orderType: nil, operator: nil, value: nil))
        )
    }

    public func loadChartData(name: FunctionNameContract, historyId: Int, arguments: FunctionArgumentsContract) async throws -> HistoryChartDetailContract {
        let values: [ChartCommonItemContract]
        switch name {
        case .queryStockGroupByOrg:
            values = [
                ChartCommonItemContract(bizId: "east", name: "华东", value: 186),
                ChartCommonItemContract(bizId: "south", name: "华南", value: 142),
                ChartCommonItemContract(bizId: "north", name: "华北", value: 98),
            ]
        case .queryArGroupByCustomer:
            values = [
                ChartCommonItemContract(bizId: "a", name: "远山贸易", value: 1260000),
                ChartCommonItemContract(bizId: "b", name: "青禾供应链", value: 880000),
                ChartCommonItemContract(bizId: "c", name: "星河制造", value: 520000),
            ]
        default:
            values = [
                ChartCommonItemContract(bizId: "w1", name: "第1周", value: 320000),
                ChartCommonItemContract(bizId: "w2", name: "第2周", value: 410000),
                ChartCommonItemContract(bizId: "w3", name: "第3周", value: 560000),
                ChartCommonItemContract(bizId: "w4", name: "第4周", value: 610000),
            ]
        }
        return HistoryChartDetailContract(historyDetailId: historyId * 10 + 2, funcType: name, chartCommonVoList: values)
    }

    public func sendLikeFeedback(historyDetailId: Int, like: String) async throws {}

    public func streamMessage(text: String) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            continuation.yield("这是预览环境的流式回复：\(text)")
            continuation.finish()
        }
    }
}

private struct PreviewHistoryItem {
    let title: String
    let question: String
    let answer: String

    static func item(for historyId: Int) -> PreviewHistoryItem {
        switch historyId {
        case 101:
            PreviewHistoryItem(
                title: "各组织库存吨数",
                question: "查看各组织库存吨数",
                answer: "当前库存主要集中在华东、华南与华北组织，其中华东库存最高。"
            )
        case 102:
            PreviewHistoryItem(
                title: "客户应收账款分析",
                question: "按客户分析应收账款",
                answer: "远山贸易、青禾供应链与星河制造为主要应收客户，建议优先跟进高账龄客户。"
            )
        case 103:
            PreviewHistoryItem(
                title: "采购金额月度对比",
                question: "采购金额按月份对比",
                answer: "采购金额近几个月呈波动上升，第 4 周采购额最高，需要关注采购节奏。"
            )
        default:
            PreviewHistoryItem(
                title: "本月销售额趋势",
                question: "查询本月销售额趋势",
                answer: "本月销售额整体向好，华东和华南贡献最高。"
            )
        }
    }
}
