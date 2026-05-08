import Testing
@testable import ModuleAI

struct SendLikeFeedbackUseCaseTests {
    @Test
    func execute_completesWhenRepositorySucceeds() async throws {
        let useCase = SendLikeFeedbackUseCase(
            repository: MockAIChatRepository()
        )

        try await useCase.execute(historyDetailId: 1, like: "1")
    }
}
