import Foundation
import Testing
@testable import ModuleAI

struct StreamAIResponseUseCaseTests {
    @Test
    func execute_forwardsRepositoryStream() async throws {
        let useCase = StreamAIResponseUseCase(
            repository: StreamOnlyMockAIChatRepository { _ in
                AsyncThrowingStream { continuation in
                    continuation.yield("a")
                    continuation.yield("b")
                    continuation.finish()
                }
            }
        )

        var chunks: [String] = []
        for try await chunk in useCase.execute(text: "hello") {
            chunks.append(chunk)
        }

        #expect(chunks == ["a", "b"])
    }
}

private struct StreamOnlyMockAIChatRepository: AIChatRepository {
    let streamFactory: (String) -> AsyncThrowingStream<String, Error>

    init(streamFactory: @escaping (String) -> AsyncThrowingStream<String, Error>) {
        self.streamFactory = streamFactory
    }

    func loadTemplate() async throws -> TemplateModel {
        throw StreamOnlyMockError.unused
    }

    func loadHistoryDetail(_ historyId: Int) async throws -> RecordModel {
        throw StreamOnlyMockError.unused
    }

    func sendFunctionMessage(_ text: String, historyId: Int?) async throws -> FunctionModel {
        throw StreamOnlyMockError.unused
    }

    func loadChartData(name: FunctionName, historyId: Int, arguments: FunctionArguments) async throws -> HistoryDetailModel {
        throw StreamOnlyMockError.unused
    }

    func sendLikeFeedback(historyDetailId: Int, like: String) async throws {
        throw StreamOnlyMockError.unused
    }

    func streamMessage(_ text: String) -> AsyncThrowingStream<String, Error> {
        streamFactory(text)
    }
}

private enum StreamOnlyMockError: Error {
    case unused
}
