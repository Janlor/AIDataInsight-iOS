import AppContracts
import AppCore
import AppNetworking
import Foundation
import Security

public struct AccountSession: Codable, Equatable, Sendable {
    public let accessToken: String
    public let refreshToken: String
    public let orgID: String
    public let username: String?

    public init(accessToken: String, refreshToken: String, orgID: String, username: String? = nil) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.orgID = orgID
        self.username = username
    }

    public var isLogin: Bool {
        accessToken.isEmpty == false
    }

    public init?(_ contract: AccountSessionContract) {
        guard let accessToken = contract.accessToken, accessToken.isEmpty == false else {
            return nil
        }
        self.accessToken = accessToken
        self.refreshToken = contract.refreshToken ?? ""
        self.orgID = contract.orgId.map(String.init) ?? ""
        self.username = contract.username
    }

    public var contract: AccountSessionContract {
        AccountSessionContract(
            accessToken: accessToken,
            refreshToken: refreshToken,
            orgId: Int(orgID),
            username: username,
            isLogin: isLogin
        )
    }
}

public protocol SessionStore: Sendable {
    func load() async throws -> AccountSession?
    func save(_ session: AccountSession) async throws
    func clear() async throws
}

public protocol AccountUserStore: Sendable {
    func load() async throws -> AccountUserContract?
    func save(_ user: AccountUserContract) async throws
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

public actor InMemoryAccountUserStore: AccountUserStore {
    private var user: AccountUserContract?

    public init(user: AccountUserContract? = nil) {
        self.user = user
    }

    public func load() async throws -> AccountUserContract? {
        user
    }

    public func save(_ user: AccountUserContract) async throws {
        self.user = user
    }

    public func clear() async throws {
        user = nil
    }
}

public struct KeychainSessionStore: SessionStore {
    private let service: String
    private let account: String
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(
        service: String = "com.aidatainsight.apple.session",
        account: String = "default",
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.service = service
        self.account = account
        self.encoder = encoder
        self.decoder = decoder
    }

    public func load() async throws -> AccountSession? {
        var query = baseQuery()
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound {
            return nil
        }
        guard status == errSecSuccess, let data = result as? Data else {
            throw AppError(kind: .transport(message: "Keychain load failed: \(status)."))
        }
        return try decoder.decode(AccountSession.self, from: data)
    }

    public func save(_ session: AccountSession) async throws {
        let data = try encoder.encode(session)
        var query = baseQuery()
        query[kSecValueData as String] = data

        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecDuplicateItem {
            let updateStatus = SecItemUpdate(baseQuery() as CFDictionary, [kSecValueData as String: data] as CFDictionary)
            guard updateStatus == errSecSuccess else {
                throw AppError(kind: .transport(message: "Keychain update failed: \(updateStatus)."))
            }
            return
        }
        guard status == errSecSuccess else {
            throw AppError(kind: .transport(message: "Keychain save failed: \(status)."))
        }
    }

    public func clear() async throws {
        let status = SecItemDelete(baseQuery() as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw AppError(kind: .transport(message: "Keychain clear failed: \(status)."))
        }
    }

    private func baseQuery() -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
        ]
    }
}

public struct KeychainAccountUserStore: AccountUserStore {
    private let service: String
    private let account: String
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(
        service: String = "com.aidatainsight.apple.user",
        account: String = "default",
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.service = service
        self.account = account
        self.encoder = encoder
        self.decoder = decoder
    }

    public func load() async throws -> AccountUserContract? {
        var query = baseQuery()
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound {
            return nil
        }
        guard status == errSecSuccess, let data = result as? Data else {
            throw AppError(kind: .transport(message: "Keychain user load failed: \(status)."))
        }
        return try decoder.decode(AccountUserContract.self, from: data)
    }

    public func save(_ user: AccountUserContract) async throws {
        let data = try encoder.encode(user)
        var query = baseQuery()
        query[kSecValueData as String] = data

        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecDuplicateItem {
            let updateStatus = SecItemUpdate(baseQuery() as CFDictionary, [kSecValueData as String: data] as CFDictionary)
            guard updateStatus == errSecSuccess else {
                throw AppError(kind: .transport(message: "Keychain user update failed: \(updateStatus)."))
            }
            return
        }
        guard status == errSecSuccess else {
            throw AppError(kind: .transport(message: "Keychain user save failed: \(status)."))
        }
    }

    public func clear() async throws {
        let status = SecItemDelete(baseQuery() as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw AppError(kind: .transport(message: "Keychain user clear failed: \(status)."))
        }
    }

    private func baseQuery() -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
        ]
    }
}

public actor AccountSessionManager: SessionCredentialManaging {
    private let store: SessionStore
    private let userStore: AccountUserStore?
    private var cachedSession: AccountSession?

    public init(store: SessionStore, userStore: AccountUserStore? = nil) {
        self.store = store
        self.userStore = userStore
    }

    public var accessToken: String? {
        get async {
            await session()?.accessToken
        }
    }

    public var refreshToken: String? {
        get async {
            await session()?.refreshToken
        }
    }

    public var orgID: String? {
        get async {
            await session()?.orgID
        }
    }

    public func loadSession() async throws -> AccountSession? {
        if let cachedSession {
            return cachedSession
        }
        let loaded = try await store.load()
        cachedSession = loaded
        return loaded
    }

    public func persist(_ session: AccountSessionContract) async throws {
        guard let accountSession = AccountSession(session) else {
            throw AppError(kind: .dataFormat)
        }
        cachedSession = accountSession
        try await store.save(accountSession)
    }

    public func clear(reason: SessionInvalidationReason) async throws {
        cachedSession = nil
        try await store.clear()
        try await userStore?.clear()
    }

    private func session() async -> AccountSession? {
        if let cachedSession {
            return cachedSession
        }
        do {
            let loaded = try await store.load()
            cachedSession = loaded
            return loaded
        } catch {
            return nil
        }
    }
}

public protocol AccountServicing: Sendable {
    func resolveLaunchSession() async throws -> AccountSession?
    func login(name: String, password: String) async throws -> AccountSession
    func cachedUserInfo() async throws -> AccountUserContract?
    func getUserInfo() async throws -> AccountUserContract
    func logout() async throws
}

public struct AccountService: AccountServicing {
    private let client: HTTPClient
    private let sessionManager: AccountSessionManager
    private let userStore: AccountUserStore
    private let encoder: JSONEncoder

    public init(
        client: HTTPClient,
        sessionManager: AccountSessionManager,
        userStore: AccountUserStore = InMemoryAccountUserStore(),
        encoder: JSONEncoder = JSONEncoder()
    ) {
        self.client = client
        self.sessionManager = sessionManager
        self.userStore = userStore
        self.encoder = encoder
    }

    public func resolveLaunchSession() async throws -> AccountSession? {
        try await sessionManager.loadSession()
    }

    public func login(name: String, password: String) async throws -> AccountSession {
        let requestBody = LoginRequestContract(name: name, pwd: password)
        let request = HTTPRequest(
            path: "/oauth2/login",
            method: .post,
            headers: ["Content-Type": "application/json"],
            body: try encoder.encode(requestBody)
        )
        let envelope = try await client.send(request, as: AccountSessionContract.self)
        guard let contract = envelope.data, let session = AccountSession(contract) else {
            throw AppError(kind: .dataFormat, traceID: envelope.trace, transactionID: envelope.tid)
        }
        try await sessionManager.persist(contract)
        _ = try? await getUserInfo()
        return session
    }

    public func cachedUserInfo() async throws -> AccountUserContract? {
        try await userStore.load()
    }

    public func getUserInfo() async throws -> AccountUserContract {
        let envelope = try await client.send(HTTPRequest(path: "/oauth2/getUserInfo"), as: AccountUserContract.self)
        guard let user = envelope.data else {
            throw AppError(kind: .dataFormat, traceID: envelope.trace, transactionID: envelope.tid)
        }
        try await userStore.save(user)
        return user
    }

    public func logout() async throws {
        _ = try? await client.send(HTTPRequest(path: "/oauth2/logout"), as: EmptyContract.self)
        try await sessionManager.clear(reason: .logout)
        try await userStore.clear()
    }
}
