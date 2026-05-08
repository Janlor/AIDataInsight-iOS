import Foundation
import Testing
@testable import ModuleAI

struct LoadTemplateUseCaseTests {
    @Test
    func execute_returnsQuestionsFromRepository() async throws {
        let useCase = LoadTemplateUseCase(
            repository: MockAIChatRepository(
                template: TemplateModel(questions: ["q1", "q2"])
            )
        )

        let output = try await useCase.execute()

        #expect(output.questions == ["q1", "q2"])
    }
}
