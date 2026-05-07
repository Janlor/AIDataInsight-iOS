import Testing
@testable import ModuleAI

struct SendFunctionMessageUseCaseTests {
    @Test
    func execute_returnsIntentWhenResolverMatches() async throws {
        let useCase = SendFunctionMessageUseCase(
            repository: MockAIChatRepository(
                functionModel: FunctionModel(
                    historyId: 1,
                    hasTool: true,
                    name: .querySalesGroupByMonth,
                    msg: nil,
                    arguments: .performanceType(PerformanceTypeQueryModel(indexType: "sales"))
                )
            )
        )

        let result = try await useCase.execute(text: "按指标分析", historyId: nil)

        guard case let .intent(text, type) = result else {
            Issue.record("Expected intent result")
            return
        }
        #expect(text == "按指标分析")
        #expect(type == .index)
    }

    @Test
    func execute_returnsChartRequestWhenToolCallNeedsNextStep() async throws {
        let useCase = SendFunctionMessageUseCase(
            repository: MockAIChatRepository(
                functionModel: FunctionModel(
                    historyId: 2,
                    hasTool: true,
                    name: .querySalesGroupByMonth,
                    msg: nil,
                    arguments: .basic(
                        BasicQueryModel(
                            orgId: 1,
                            customerName: nil,
                            orderType: nil,
                            operator: nil,
                            value: 1
                        )
                    )
                )
            )
        )

        let result = try await useCase.execute(text: "销售额", historyId: nil)

        guard case let .chartRequest(name, historyId, _) = result else {
            Issue.record("Expected chart request result")
            return
        }
        #expect(name == .querySalesGroupByMonth)
        #expect(historyId == 2)
    }
}
