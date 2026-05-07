import Testing
@testable import ModuleAI

struct LoadChartDataUseCaseTests {
    @Test
    func execute_returnsSuccessWhenChartDataExists() async throws {
        let useCase = LoadChartDataUseCase(
            repository: MockAIChatRepository(
                historyDetailModel: HistoryDetailModel(
                    funcType: .querySalesGroupByMonth,
                    chartCommonVoList: [
                        ChartCommonVo(bizId: "1", name: "一月", value: 10)
                    ],
                    accountAgeGroupVoList: nil
                )
            )
        )

        let result = try await useCase.execute(
            name: .querySalesGroupByMonth,
            historyId: 1,
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

        guard case let .success(funcType, datas) = result else {
            Issue.record("Expected success result")
            return
        }
        #expect(funcType == .querySalesGroupByMonth)
        #expect(datas.count == 1)
    }

    @Test
    func execute_returnsFailureWhenChartBuilderHasNoData() async throws {
        let useCase = LoadChartDataUseCase(
            repository: MockAIChatRepository(
                historyDetailModel: HistoryDetailModel(
                    funcType: nil,
                    chartCommonVoList: nil,
                    accountAgeGroupVoList: nil
                )
            )
        )

        let result = try await useCase.execute(
            name: .querySalesGroupByMonth,
            historyId: 1,
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

        guard case let .failure(message) = result else {
            Issue.record("Expected failure result")
            return
        }
        #expect(message != nil)
    }
}
