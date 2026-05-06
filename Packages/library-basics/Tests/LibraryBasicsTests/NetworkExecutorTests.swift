import Foundation
import Testing
import Moya
@testable import Networking

@Suite(.serialized)
struct NetworkExecutorTests {
    @Test
    func requestData_success200_returnsPayload() async throws {
        let client = MockNetworkClient(responses: [
            .success(jsonResponse(statusCode: 200, body: #"{"code":200,"msg":"ok","data":{"name":"demo"}}"#))
        ])
        let executor = NetworkExecutor(
            networkClient: client,
            credentialProvider: MockCredentialProvider(refreshToken: "refresh-token"),
            tokenRefreshService: MockTokenRefreshService(),
            sessionInvalidationHandler: MockInvalidationHandler()
        )

        let data = try await executor.requestData(MockTarget(path: "/demo"))
        let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

        #expect(json["code"] as? Int == 200)
    }

    @Test
    func requestData_401_invalidatesSessionAndThrows() async {
        let invalidationHandler = MockInvalidationHandler()
        let client = MockNetworkClient(responses: [
            .success(jsonResponse(statusCode: 200, body: #"{"code":401,"msg":"expired"}"#))
        ])
        let executor = NetworkExecutor(
            networkClient: client,
            credentialProvider: MockCredentialProvider(refreshToken: "refresh-token"),
            tokenRefreshService: MockTokenRefreshService(),
            sessionInvalidationHandler: invalidationHandler
        )

        await #expect(throws: MoyaError.self) {
            _ = try await executor.requestData(MockTarget(path: "/demo"))
        }
        #expect(invalidationHandler.lastMessage == "expired")
    }

    @Test
    func requestData_402_refreshesAndRetriesOnce() async throws {
        let refreshService = MockTokenRefreshService()
        let client = MockNetworkClient(responses: [
            .success(jsonResponse(statusCode: 200, body: #"{"code":402,"msg":"refresh"}"#)),
            .success(jsonResponse(statusCode: 200, body: #"{"code":200,"msg":"ok","data":{"value":1}}"#))
        ])
        let executor = NetworkExecutor(
            networkClient: client,
            credentialProvider: MockCredentialProvider(refreshToken: "refresh-token"),
            tokenRefreshService: refreshService,
            sessionInvalidationHandler: MockInvalidationHandler()
        )

        let data = try await executor.requestData(MockTarget(path: "/demo"))
        let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

        #expect(refreshService.receivedTokens == ["refresh-token"])
        #expect((json["code"] as? Int) == 200)
        #expect(await client.requestCount == 2)
    }
}

private struct MockTarget: CustomTargetType {
    let baseURL: URL = URL(string: "https://example.com")!
    let path: String
    let method: Moya.Method = .post
    let parameters: [String : Any] = [:]
    let task: Moya.Task = .requestPlain
    let headers: [String : String]? = nil
    let sampleData: Data = Data()
}

private actor MockNetworkClient: NetworkClient {
    enum MockResult {
        case success(NetworkClientResponse)
        case failure(Error)
    }

    private var queue: [MockResult]
    private(set) var requestCount = 0

    init(responses: [MockResult]) {
        self.queue = responses
    }

    func send(_ request: URLRequest) async throws -> NetworkClientResponse {
        requestCount += 1
        guard queue.isEmpty == false else {
            throw URLError(.badServerResponse)
        }

        let next = queue.removeFirst()
        switch next {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }
}

private struct MockCredentialProvider: NetworkCredentialProvider {
    let accessToken: String? = nil
    let refreshToken: String?
    let orgId: Int? = nil
}

private final class MockTokenRefreshService: TokenRefreshService {
    private(set) var receivedTokens: [String] = []

    func refreshToken(_ token: String, completion: @escaping (Bool, String?) -> Void) -> Moya.Cancellable? {
        receivedTokens.append(token)
        completion(true, nil)
        return nil
    }
}

private final class MockInvalidationHandler: SessionInvalidationHandler {
    private(set) var lastMessage: String?

    func invalidateSession(message: String?) {
        lastMessage = message
    }
}

private func jsonResponse(statusCode: Int, body: String) -> NetworkClientResponse {
    let url = URL(string: "https://example.com/demo")!
    let response = HTTPURLResponse(
        url: url,
        statusCode: statusCode,
        httpVersion: nil,
        headerFields: ["Content-Type": "application/json"]
    )!
    return NetworkClientResponse(data: Data(body.utf8), response: response)
}
