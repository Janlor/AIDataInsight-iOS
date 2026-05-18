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

@Test func historySectionKindsMatchContractOrder() {
    #expect(HistorySectionKindContract.allCases == [.today, .thisMonth, .other])
}
