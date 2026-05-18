import Testing
@testable import AppPersistence

@Test func persistenceBoundaryKeepsTokensOutOfSwiftData() throws {
    #expect(PersistenceBoundary.sensitiveSessionStorage == "Keychain")
    #expect(PersistenceBoundary.nonSensitiveCacheStorage == "SwiftData")
}
