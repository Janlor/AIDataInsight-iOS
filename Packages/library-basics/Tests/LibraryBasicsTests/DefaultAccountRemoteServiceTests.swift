import Foundation
import Testing
@testable import Account
import AccountProtocol
@testable import Networking

@Suite(.serialized)
struct DefaultAccountRemoteServiceTests {
    @Test
    func getUserInfo_success_updatesStoreAndReturnsModel() async throws {
        let store = MockAccountUserStore()
        let client = MockNetworkClient(responses: [
            .success(jsonResponse(body: #"{"code":200,"msg":"ok","data":{"id":1,"phone":"13800000000","username":"demo","nikeName":"Demo"}}"#))
        ])
        let service = DefaultAccountRemoteService(
            accountUserStore: store,
            networkExecutor: NetworkExecutor(
                networkClient: client,
                credentialProvider: MockCredentialProvider(refreshToken: "refresh-token"),
                tokenRefreshCoordinator: TokenRefreshCoordinator(tokenRefreshService: MockTokenRefreshService()),
                sessionInvalidationHandler: MockInvalidationHandler()
            )
        )

        let result: (UserInfoMO?, String?) = await withCheckedContinuation { continuation in
            service.getUserInfo { (model: UserInfoMO?, message: String?) in
                continuation.resume(returning: (model, message))
            }
        }

        #expect(result.0?.username == "demo")
        #expect(result.1 == nil)
        #expect(store.lastUser?.username == "demo")
    }

    @Test
    func getMenuTree_failure_returnsMessageWithoutUpdatingStore() async {
        let store = MockAccountUserStore()
        let client = MockNetworkClient(responses: [
            .success(jsonResponse(body: #"{"code":500,"msg":"server error"}"#))
        ])
        let service = DefaultAccountRemoteService(
            accountUserStore: store,
            networkExecutor: NetworkExecutor(
                networkClient: client,
                credentialProvider: MockCredentialProvider(refreshToken: "refresh-token"),
                tokenRefreshCoordinator: TokenRefreshCoordinator(tokenRefreshService: MockTokenRefreshService()),
                sessionInvalidationHandler: MockInvalidationHandler()
            )
        )

        let result: ([MenuModel]?, String?) = await withCheckedContinuation { continuation in
            service.getMenuTree { (models: [MenuModel]?, message: String?) in
                continuation.resume(returning: (models, message))
            }
        }

        #expect(result.0 == nil)
        #expect(result.1 == "server error")
        #expect(store.lastMenus == nil)
    }
}

private final class MockAccountUserStore: AccountUserStore {
    private(set) var lastUser: UserInfoMO?
    private(set) var lastMenus: [MenuModel]?

    @discardableResult
    func updateUser<T>(_ info: T) -> Bool where T : UserInfo, T : Codable {
        lastUser = info as? UserInfoMO
        return true
    }

    @discardableResult
    func updateUserOrgList<T>(_ info: [T]) -> Bool where T : UserOrgProtocal, T : Codable {
        true
    }

    @discardableResult
    func update<T>(userOrg info: T) -> Bool where T : UserOrgProtocal, T : Codable {
        true
    }

    @discardableResult
    func update<T>(menus info: [T]) -> Bool where T : MenuProtocol, T : Codable {
        lastMenus = info as? [MenuModel]
        return true
    }

    func getUser<T>(_ type: T.Type) -> T? where T : UserInfo, T : Codable {
        lastUser as? T
    }

    func fetchUserOrgList<T>(_ type: T.Type) -> [T]? where T : UserOrgProtocal, T : Codable {
        nil
    }

    func fetch<T>(userOrg type: T.Type) -> T? where T : UserOrgProtocal, T : Codable {
        nil
    }

    func fetch<T>(menu type: T.Type) -> [T]? where T : MenuProtocol, T : Codable {
        lastMenus as? [T]
    }
}

private struct MockCredentialProvider: NetworkCredentialProvider {
    let accessToken: String? = nil
    let refreshToken: String?
    let orgId: Int? = nil
}

private final class MockTokenRefreshService: @unchecked Sendable, TokenRefreshService {
    func refreshToken(_ token: String, completion: @escaping (Bool, String?) -> Void) -> Cancellable? {
        completion(true, nil)
        return nil
    }
}

private final class MockInvalidationHandler: @unchecked Sendable, SessionInvalidationHandler {
    func invalidateSession(message: String?) {}
}

private actor MockNetworkClient: NetworkClient {
    enum MockResult {
        case success(NetworkClientResponse)
        case failure(Error)
    }

    private var queue: [MockResult]

    init(responses: [MockResult]) {
        self.queue = responses
    }

    func send(_ request: URLRequest) async throws -> NetworkClientResponse {
        guard queue.isEmpty == false else {
            throw URLError(.badServerResponse)
        }

        switch queue.removeFirst() {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }
}

private func jsonResponse(body: String) -> NetworkClientResponse {
    let url = URL(string: "https://example.com/account")!
    let response = HTTPURLResponse(
        url: url,
        statusCode: 200,
        httpVersion: nil,
        headerFields: ["Content-Type": "application/json"]
    )!
    return NetworkClientResponse(data: Data(body.utf8), response: response)
}
