import Testing
@testable import ModuleAI

struct DeleteAllHistoryUseCaseTests {
    @Test
    func execute_returnsClearedState() async throws {
        let useCase = DeleteAllHistoryUseCase(repository: MockHistoryRepository())

        let state = try await useCase.execute()

        #expect(state.recordGroups.isEmpty)
        #expect(state.pageModel == nil)
    }
}
