import Testing
@testable import ModuleAI

struct ChartApiTests {
    @Test
    func chart_usesFunctionNameAsPathAndArgumentsAsParameters() {
        let api = ChartApi.chart(
            .querySalesGroupByMonth,
            123,
            .timeRange(
                TimeRangeQueryModel(
                    startDate: "2026-01-01",
                    endDate: "2026-01-31",
                    orgId: 1,
                    customerName: "ACME",
                    goodsType: 2,
                    orderType: "sales",
                    operator: ">",
                    value: 10.5
                )
            )
        )
        
        #expect(api.path == "/chart/querySalesGroupByMonth")
        #expect(api.parameters["historyId"] as? Int == 123)
        #expect(api.parameters["startDate"] as? String == "2026-01-01")
        #expect(api.parameters["endDate"] as? String == "2026-01-31")
        #expect(api.parameters["orgId"] as? Int == 1)
        #expect(api.parameters["customerName"] as? String == "ACME")
        #expect(api.parameters["goodsType"] as? Int == 2)
        #expect(api.parameters["orderType"] as? String == "sales")
        #expect(api.parameters["operator"] as? String == ">")
        #expect(api.parameters["value"] as? Double == 10.5)
    }
}

