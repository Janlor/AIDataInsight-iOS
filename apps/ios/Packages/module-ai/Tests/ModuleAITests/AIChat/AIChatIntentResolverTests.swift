import Testing
@testable import ModuleAI

struct AIChatIntentResolverTests {
    @Test
    func resolve_timeRangeWithoutStartDate_returnsTimeIntent() {
        let arguments = FunctionArguments.timeRange(
            TimeRangeQueryModel(
                startDate: nil,
                endDate: "2025-01-31",
                orgId: 1,
                customerName: nil,
                goodsType: nil,
                orderType: nil,
                operator: nil,
                value: nil
            )
        )

        let result = AIChatIntentResolver.resolve(arguments: arguments)

        #expect(result == .time)
    }

    @Test
    func resolve_performanceType_returnsIndexIntent() {
        let arguments = FunctionArguments.performanceType(
            PerformanceTypeQueryModel(indexType: "sales")
        )

        let result = AIChatIntentResolver.resolve(arguments: arguments)

        #expect(result == .index)
    }

    @Test
    func resolve_basicArguments_returnsNil() {
        let arguments = FunctionArguments.basic(
            BasicQueryModel(
                orgId: 1,
                customerName: "A",
                orderType: nil,
                operator: nil,
                value: 10
            )
        )

        let result = AIChatIntentResolver.resolve(arguments: arguments)

        #expect(result == nil)
    }
}
