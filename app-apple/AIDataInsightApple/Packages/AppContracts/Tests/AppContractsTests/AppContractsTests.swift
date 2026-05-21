import Foundation
import Testing
@testable import AppContracts

@Test func responseEnvelopeDecodesContractShape() throws {
    struct Payload: Decodable, Equatable, Sendable {
        let name: String
    }

    let data = Data(#"{"code":0,"msg":"ok","data":{"name":"demo"},"trace":"trace-1","tid":"tid-1"}"#.utf8)
    let envelope = try JSONDecoder().decode(APIResponseEnvelope<Payload>.self, from: data)

    #expect(envelope.code == 0)
    #expect(envelope.msg == "ok")
    #expect(envelope.data == Payload(name: "demo"))
    #expect(envelope.trace == "trace-1")
    #expect(envelope.tid == "tid-1")
}

@Test func functionNameContractKeepsContractCoverage() {
    #expect(FunctionNameContract.allCases.count == 18)
    #expect(FunctionNameContract.querySalesGroupByMonth.rawValue == "querySalesGroupByMonth")
}

@Test func functionModelDecodesObjectArgumentsByFunctionName() throws {
    let data = Data("""
    {
      "historyId": 123,
      "hasTool": true,
      "name": "querySalesGroupByMonth",
      "msg": null,
      "arguments": {
        "startDate": "2026-01-01",
        "endDate": "2026-01-31",
        "orgId": 1,
        "customerName": null,
        "goodsType": null,
        "orderType": null,
        "operator": null,
        "value": null
      }
    }
    """.utf8)

    let model = try JSONDecoder().decode(FunctionModelContract.self, from: data)

    #expect(model.name == .querySalesGroupByMonth)
    guard case .timeRange(let arguments) = model.arguments else {
        Issue.record("Expected timeRange arguments.")
        return
    }
    #expect(arguments.startDate == "2026-01-01")
    #expect(arguments.endDate == "2026-01-31")
    #expect(arguments.orgId == 1)
}

@Test func functionModelDecodesJSONStringArgumentsByFunctionName() throws {
    let data = Data(#"""
    {
      "historyId": 123,
      "hasTool": true,
      "name": "querySalesGroupByMonth",
      "msg": null,
      "arguments": "{\"startDate\":\"2026-01-01\",\"endDate\":\"2026-01-31\",\"orgId\":1,\"customerName\":null,\"goodsType\":null,\"orderType\":null,\"operator\":null,\"value\":null}"
    }
    """#.utf8)

    let model = try JSONDecoder().decode(FunctionModelContract.self, from: data)

    guard case .timeRange(let arguments) = model.arguments else {
        Issue.record("Expected timeRange arguments.")
        return
    }
    #expect(arguments.startDate == "2026-01-01")
    #expect(arguments.endDate == "2026-01-31")
    #expect(arguments.orgId == 1)
}

@Test func functionModelKeepsWrappedArgumentsCompatibility() throws {
    let data = Data("""
    {
      "historyId": 321,
      "hasTool": true,
      "name": "queryPerformanceType",
      "msg": null,
      "arguments": {
        "kind": "performanceType",
        "value": {
          "indexType": "grossMargin"
        }
      }
    }
    """.utf8)

    let model = try JSONDecoder().decode(FunctionModelContract.self, from: data)

    guard case .performanceType(let arguments) = model.arguments else {
        Issue.record("Expected performanceType arguments.")
        return
    }
    #expect(arguments.indexType == "grossMargin")
}

@Test func historySectionKindsMatchContractOrder() {
    #expect(HistorySectionKindContract.allCases == [.today, .thisMonth, .other])
}
