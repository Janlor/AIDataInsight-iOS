import Foundation

public struct AccountSession: Equatable, Sendable {
    public let accessToken: String
    public let refreshToken: String
    public let orgID: String

    public init(accessToken: String, refreshToken: String, orgID: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.orgID = orgID
    }
}

public protocol SessionStore: Sendable {
    func load() async throws -> AccountSession?
    func save(_ session: AccountSession) async throws
    func clear() async throws
}

public actor InMemorySessionStore: SessionStore {
    private var session: AccountSession?

    public init(session: AccountSession? = nil) {
        self.session = session
    }

    public func load() async throws -> AccountSession? {
        session
    }

    public func save(_ session: AccountSession) async throws {
        self.session = session
    }

    public func clear() async throws {
        session = nil
    }
}
