import Foundation
import Testing
@testable import ModuleAI

@Suite(.serialized)
struct AIChatViewModelStreamTests {
    @MainActor
    @Test
    func sendStreamMessage_success_emitsChunksAndCompletion() async {
        let repository = MockAIChatRepository { _ in
            AsyncThrowingStream { continuation in
                continuation.yield("hello")
                continuation.yield("world")
                continuation.finish()
            }
        }
        let viewModel = AIChatViewModel(repository: repository)
        let recorder = StreamEventRecorder()

        viewModel.onStreamText = { text in
            Task { await recorder.append(text) }
        }
        viewModel.onStreamCompleted = {
            Task { await recorder.finish() }
        }
        viewModel.onStreamFailed = { message in
            Task { await recorder.fail(message) }
        }

        viewModel.sendStreamMessage("test")
        let result = await recorder.waitForTerminalEvent()

        #expect(result.chunks == ["hello", "world"])
        #expect(result.completed == true)
        #expect(result.failureMessage == nil)
    }

    @MainActor
    @Test
    func sendStreamMessage_failure_emitsFailure() async {
        let repository = MockAIChatRepository { _ in
            AsyncThrowingStream { continuation in
                continuation.finish(throwing: MockStreamError.failed)
            }
        }
        let viewModel = AIChatViewModel(repository: repository)
        let recorder = StreamEventRecorder()

        viewModel.onStreamCompleted = {
            Task { await recorder.finish() }
        }
        viewModel.onStreamFailed = { message in
            Task { await recorder.fail(message) }
        }

        viewModel.sendStreamMessage("test")
        let result = await recorder.waitForTerminalEvent()

        #expect(result.completed == false)
        #expect(result.failureMessage?.contains("failed") == true)
    }

    @MainActor
    @Test
    func cancelStream_afterFirstChunk_doesNotEmitFailureOrCompletion() async throws {
        let firstChunk = StreamSignal()
        let repository = MockAIChatRepository { _ in
            AsyncThrowingStream { continuation in
                Task {
                    continuation.yield("first")
                    await firstChunk.send()
                    try? await Task.sleep(nanoseconds: 500_000_000)
                    continuation.yield("second")
                    continuation.finish()
                }
            }
        }
        let viewModel = AIChatViewModel(repository: repository)
        let recorder = StreamEventRecorder()

        viewModel.onStreamText = { text in
            Task { await recorder.append(text) }
        }
        viewModel.onStreamCompleted = {
            Task { await recorder.finish() }
        }
        viewModel.onStreamFailed = { message in
            Task { await recorder.fail(message) }
        }

        viewModel.sendStreamMessage("test")
        await firstChunk.wait()
        viewModel.cancelStream()
        try await Task.sleep(nanoseconds: 200_000_000)
        let snapshot = await recorder.snapshot()

        #expect(snapshot.chunks == ["first"])
        #expect(snapshot.completed == false)
        #expect(snapshot.failureMessage == nil)
    }
}

private struct MockAIChatRepository: AIChatRepository {
    let streamFactory: (String) -> AsyncThrowingStream<String, Error>

    init(streamFactory: @escaping (String) -> AsyncThrowingStream<String, Error>) {
        self.streamFactory = streamFactory
    }

    func loadTemplate() async throws -> TemplateModel {
        throw MockStreamError.unused
    }

    func loadHistoryDetail(_ historyId: Int) async throws -> RecordModel {
        throw MockStreamError.unused
    }

    func sendFunctionMessage(_ text: String, historyId: Int?) async throws -> FunctionModel {
        throw MockStreamError.unused
    }

    func loadChartData(name: FunctionName, historyId: Int, arguments: FunctionArguments) async throws -> HistoryDetailModel {
        throw MockStreamError.unused
    }

    func sendLikeFeedback(historyDetailId: Int, like: String) async throws {
        throw MockStreamError.unused
    }

    func streamMessage(_ text: String) -> AsyncThrowingStream<String, Error> {
        streamFactory(text)
    }
}

private enum MockStreamError: LocalizedError {
    case failed
    case unused

    var errorDescription: String? {
        switch self {
        case .failed:
            return "stream failed"
        case .unused:
            return "unused"
        }
    }
}

private actor StreamEventRecorder {
    private var chunks: [String] = []
    private var completed = false
    private var failureMessage: String?
    private var continuation: CheckedContinuation<Snapshot, Never>?

    struct Snapshot {
        let chunks: [String]
        let completed: Bool
        let failureMessage: String?
    }

    func append(_ chunk: String) {
        chunks.append(chunk)
    }

    func finish() {
        completed = true
        resumeIfNeeded()
    }

    func fail(_ message: String?) {
        failureMessage = message
        resumeIfNeeded()
    }

    func waitForTerminalEvent() async -> Snapshot {
        if completed || failureMessage != nil {
            return Snapshot(chunks: chunks, completed: completed, failureMessage: failureMessage)
        }

        return await withCheckedContinuation { continuation in
            self.continuation = continuation
        }
    }

    func snapshot() -> Snapshot {
        Snapshot(chunks: chunks, completed: completed, failureMessage: failureMessage)
    }

    private func resumeIfNeeded() {
        guard let continuation else { return }
        continuation.resume(returning: Snapshot(chunks: chunks, completed: completed, failureMessage: failureMessage))
        self.continuation = nil
    }
}

private actor StreamSignal {
    private var continuation: CheckedContinuation<Void, Never>?
    private var signaled = false

    func send() {
        signaled = true
        continuation?.resume()
        continuation = nil
    }

    func wait() async {
        if signaled { return }
        await withCheckedContinuation { continuation in
            self.continuation = continuation
        }
    }
}
