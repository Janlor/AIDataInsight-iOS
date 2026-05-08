import Foundation
import Testing
@testable import ModuleAI

struct LoadHistoryDetailUseCaseTests {
    @Test
    func execute_mapsDetailListToChats() async throws {
        let record = RecordModel(
            id: 1,
            name: nil,
            createId: nil,
            updateId: nil,
            createName: nil,
            updateName: nil,
            createTime: nil,
            updateTime: nil,
            detailList: [
                DetailModel(
                    id: 1,
                    historyId: 1,
                    type: .question,
                    contentType: nil,
                    content: "hello",
                    isLike: nil,
                    createTime: nil,
                    updateTime: nil
                )
            ]
        )
        let useCase = LoadHistoryDetailUseCase(
            repository: MockAIChatRepository(record: record)
        )

        let chats = try await useCase.execute(historyId: 1)

        #expect(chats.count == 1)
        #expect(chats.first?.text == "hello")
        #expect(chats.first?.type == .user)
    }
}
