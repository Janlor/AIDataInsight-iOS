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

        let output = try await useCase.execute(historyId: 1)

        #expect(output.messages.count == 1)
        #expect(output.messages.first?.text == "hello")
        #expect(output.messages.first?.role == .user)
        #expect(output.messages.first?.contentKind == .text)
    }
    
    @Test
    func execute_mapsEmptyChartContentToFallbackMessage() async throws {
        let rawChartJSON = #"{"funcType":"querySalesGroupByMonth","chartCommonVoList":null,"accountAgeGroupVoList":null}"#
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
                    type: .answer,
                    contentType: .chart,
                    content: rawChartJSON,
                    isLike: nil,
                    createTime: nil,
                    updateTime: nil
                )
            ]
        )
        let useCase = LoadHistoryDetailUseCase(
            repository: MockAIChatRepository(record: record)
        )

        let output = try await useCase.execute(historyId: 1)

        #expect(output.messages.count == 1)
        #expect(output.messages.first?.contentKind == .text)
        #expect(output.messages.first?.text == "数据分析还在测试阶段，很快就能上线，敬请期待！")
        #expect(output.messages.first?.text != rawChartJSON)
    }
}
