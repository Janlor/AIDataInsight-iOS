import Testing
import AppContracts
import AppNetworking
import Foundation
@testable import AppAccount

@Test func inMemorySessionStoreSavesAndClearsSession() async throws {
    let store = InMemorySessionStore()
    let session = AccountSession(accessToken: "access", refreshToken: "refresh", orgID: "org")

    try await store.save(session)
    #expect(try await store.load() == session)

    try await store.clear()
    #expect(try await store.load() == nil)
}

@Test func accountSessionContractNormalizesWireAliases() throws {
    let data = Data(#"{"access_token":"access","refresh_token":"refresh","org_id":7}"#.utf8)
    let contract = try JSONDecoder().decode(AccountSessionContract.self, from: data)

    #expect(contract.accessToken == "access")
    #expect(contract.refreshToken == "refresh")
    #expect(contract.orgId == 7)
    #expect(contract.isLogin)
}

@Test func accountServicePersistsSessionAfterLogin() async throws {
    let store = InMemorySessionStore()
    let manager = AccountSessionManager(store: store)
    let client = MockHTTPClient(envelope: APIResponseEnvelope(
        code: 200,
        msg: "ok",
        data: AccountSessionContract(
            accessToken: "access",
            refreshToken: "refresh",
            orgId: 9,
            username: "demo",
            isLogin: true
        )
    ))
    let service = AccountService(client: client, sessionManager: manager)

    let session = try await service.login(name: "demo", password: "demo@123")

    #expect(session.accessToken == "access")
    #expect(try await store.load()?.username == "demo")
}

@Test func accountServiceClearsSessionOnLogout() async throws {
    let store = InMemorySessionStore(session: AccountSession(accessToken: "access", refreshToken: "refresh", orgID: "9"))
    let manager = AccountSessionManager(store: store)
    let client = MockHTTPClient(envelope: APIResponseEnvelope(code: 200, msg: "ok", data: EmptyContract()))
    let service = AccountService(client: client, sessionManager: manager)

    try await service.logout()

    #expect(try await store.load() == nil)
}

private struct MockHTTPClient<Payload: Decodable & Sendable>: HTTPClient {
    let envelope: APIResponseEnvelope<Payload>

    func send<ResponsePayload: Decodable & Sendable>(_ request: HTTPRequest, as payloadType: ResponsePayload.Type) async throws -> APIResponseEnvelope<ResponsePayload> {
        guard let envelope = envelope as? APIResponseEnvelope<ResponsePayload> else {
            throw AppAccountTestError.payloadMismatch
        }
        return envelope
    }
}

private enum AppAccountTestError: Error {
    case payloadMismatch
}
