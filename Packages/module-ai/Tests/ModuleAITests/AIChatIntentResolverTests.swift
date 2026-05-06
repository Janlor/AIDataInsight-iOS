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

        let result = AIChatIntentResolver.resolve(text: "近30天销售额", arguments: arguments)

        guard case let .intent(text, type)? = result else {
            Issue.record("Expected time intent result")
            return
        }
        #expect(text == "近30天销售额")
        #expect(type == .time)
    }

    @Test
    func resolve_performanceType_returnsIndexIntent() {
        let arguments = FunctionArguments.performanceType(
            PerformanceTypeQueryModel(indexType: "sales")
        )

        let result = AIChatIntentResolver.resolve(text: "按指标分析", arguments: arguments)

        guard case let .intent(text, type)? = result else {
            Issue.record("Expected index intent result")
            return
        }
        #expect(text == "按指标分析")
        #expect(type == .index)
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

        let result = AIChatIntentResolver.resolve(text: "普通问题", arguments: arguments)

        #expect(result == nil)
    }
}
