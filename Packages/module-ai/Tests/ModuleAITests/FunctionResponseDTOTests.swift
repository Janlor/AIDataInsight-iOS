import Foundation
import Testing
@testable import ModuleAI

struct FunctionResponseDTOTests {
    @Test
    func decode_timeRangeArguments_mapsToDomainModel() throws {
        let json = """
        {
          "historyId": 12,
          "hasTool": true,
          "name": "querySalesGroupByMonth",
          "msg": "ok",
          "arguments": {
            "startDate": "2025-01-01",
            "endDate": "2025-01-31",
            "orgId": 1001,
            "customerName": "ACME",
            "goodsType": 2,
            "orderType": "sales",
            "operator": ">",
            "value": 10.5
          }
        }
        """.data(using: .utf8)!

        let dto = try JSONDecoder().decode(FunctionResponseDTO.self, from: json)
        let model = dto.toDomainModel()

        #expect(model.historyId == 12)
        #expect(model.hasTool == true)
        #expect(model.name == .querySalesGroupByMonth)
        #expect(model.msg == "ok")

        guard case let .timeRange(arguments)? = model.arguments else {
            Issue.record("Expected timeRange arguments")
            return
        }

        #expect(arguments.startDate == "2025-01-01")
        #expect(arguments.endDate == "2025-01-31")
        #expect(arguments.orgId == 1001)
        #expect(arguments.customerName == "ACME")
        #expect(arguments.goodsType == 2)
        #expect(arguments.orderType == "sales")
        #expect(arguments.operator == ">")
        #expect(arguments.value == 10.5)
    }

    @Test
    func decode_performanceTypeArguments_mapsToDomainModel() throws {
        let json = """
        {
          "historyId": 88,
          "hasTool": true,
          "name": "queryPerformanceType",
          "arguments": {
            "indexType": "profit"
          }
        }
        """.data(using: .utf8)!

        let dto = try JSONDecoder().decode(FunctionResponseDTO.self, from: json)
        let model = dto.toDomainModel()

        guard case let .performanceType(arguments)? = model.arguments else {
            Issue.record("Expected performanceType arguments")
            return
        }

        #expect(model.name == .queryPerformanceType)
        #expect(arguments.indexType == "profit")
    }

    @Test
    func decode_withoutName_keepsArgumentsNil() throws {
        let json = """
        {
          "historyId": 3,
          "hasTool": false,
          "arguments": {
            "foo": "bar"
          }
        }
        """.data(using: .utf8)!

        let dto = try JSONDecoder().decode(FunctionResponseDTO.self, from: json)
        let model = dto.toDomainModel()

        #expect(model.name == nil)
        #expect(model.arguments == nil)
    }
}
