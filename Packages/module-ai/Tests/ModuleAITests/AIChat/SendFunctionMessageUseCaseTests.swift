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

        guard case let .success(output) = result,
              case let .intent(text, type) = output else {
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

        guard case let .success(output) = result,
              case let .chartRequest(name, historyId, _) = output else {
            Issue.record("Expected chart request result")
            return
        }
        #expect(name == .querySalesGroupByMonth)
        #expect(historyId == 2)
    }

    @Test
    func execute_returnsFailureWhenHistoryIdIsMissing() async throws {
        let useCase = SendFunctionMessageUseCase(
            repository: MockAIChatRepository(
                functionModel: FunctionModel(
                    historyId: nil,
                    hasTool: true,
                    name: .querySalesGroupByMonth,
                    msg: "bad response",
                    arguments: .performanceType(PerformanceTypeQueryModel(indexType: "sales"))
                )
            )
        )

        let result = try await useCase.execute(text: "test", historyId: nil)

        guard case let .failure(failure) = result else {
            Issue.record("Expected failure result")
            return
        }
        #expect(failure.message == "bad response")
    }

    @Test
    func execute_throwsWhenRepositoryThrows() async {
        let useCase = SendFunctionMessageUseCase(
            repository: MockAIChatRepository(
                sendFunctionMessageError: TestError.failed
            )
        )

        await #expect(throws: TestError.self) {
            _ = try await useCase.execute(text: "test", historyId: nil)
        }
    }
}

private enum TestError: Error {
    case failed
}
