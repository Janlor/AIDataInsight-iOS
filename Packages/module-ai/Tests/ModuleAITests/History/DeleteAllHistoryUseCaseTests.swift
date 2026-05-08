import Testing
@testable import ModuleAI

struct DeleteAllHistoryUseCaseTests {
    @Test
    func execute_returnsClearedState() async throws {
        let useCase = DeleteAllHistoryUseCase(repository: MockHistoryRepository())

        let result = try await useCase.execute()

        #expect(result.recordGroups.isEmpty)
        #expect(result.sections.isEmpty)
        #expect(result.pageModel == nil)
    }
}
