import Testing
@testable import AppAccount

@Test func inMemorySessionStoreSavesAndClearsSession() async throws {
    let store = InMemorySessionStore()
    let session = AccountSession(accessToken: "access", refreshToken: "refresh", orgID: "org")

    try await store.save(session)
    #expect(try await store.load() == session)

    try await store.clear()
    #expect(try await store.load() == nil)
}

