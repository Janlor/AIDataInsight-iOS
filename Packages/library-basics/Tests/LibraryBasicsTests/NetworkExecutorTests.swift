import Foundation
import Testing
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
            tokenRefreshCoordinator: TokenRefreshCoordinator(tokenRefreshService: MockTokenRefreshService()),
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
            tokenRefreshCoordinator: TokenRefreshCoordinator(tokenRefreshService: MockTokenRefreshService()),
            sessionInvalidationHandler: invalidationHandler
        )

        await #expect(throws: NetworkError.self) {
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
            tokenRefreshCoordinator: TokenRefreshCoordinator(tokenRefreshService: refreshService),
            sessionInvalidationHandler: MockInvalidationHandler()
        )

        let data = try await executor.requestData(MockTarget(path: "/demo"))
        let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

        #expect(refreshService.receivedTokens == ["refresh-token"])
        #expect((json["code"] as? Int) == 200)
        #expect(await client.requestCount == 2)
    }

    @Test
    func requestData_concurrent402_refreshesOnlyOnce() async throws {
        let refreshService = MockTokenRefreshService()
        let client = MockNetworkClient(responses: [
            .success(jsonResponse(statusCode: 200, body: #"{"code":402,"msg":"refresh"}"#)),
            .success(jsonResponse(statusCode: 200, body: #"{"code":402,"msg":"refresh"}"#)),
            .success(jsonResponse(statusCode: 200, body: #"{"code":200,"msg":"ok","data":{"value":1}}"#)),
            .success(jsonResponse(statusCode: 200, body: #"{"code":200,"msg":"ok","data":{"value":2}}"#))
        ])
        let executor = NetworkExecutor(
            networkClient: client,
            credentialProvider: MockCredentialProvider(refreshToken: "refresh-token"),
            tokenRefreshCoordinator: TokenRefreshCoordinator(tokenRefreshService: refreshService),
            sessionInvalidationHandler: MockInvalidationHandler()
        )

        async let first = executor.requestData(MockTarget(path: "/demo"))
        async let second = executor.requestData(MockTarget(path: "/demo"))
        _ = try await (first, second)

        #expect(refreshService.receivedTokens == ["refresh-token"])
        #expect(await client.requestCount == 4)
    }

    @Test
    func requestData_concurrent402_refreshFailure_failsAllWaiters() async {
        let refreshService = ConfigurableMockTokenRefreshService(behavior: .failure("refresh failed"))
        let client = MockNetworkClient(responses: [
            .success(jsonResponse(statusCode: 200, body: #"{"code":402,"msg":"refresh"}"#)),
            .success(jsonResponse(statusCode: 200, body: #"{"code":402,"msg":"refresh"}"#))
        ])
        let executor = NetworkExecutor(
            networkClient: client,
            credentialProvider: MockCredentialProvider(refreshToken: "refresh-token"),
            tokenRefreshCoordinator: TokenRefreshCoordinator(tokenRefreshService: refreshService),
            sessionInvalidationHandler: MockInvalidationHandler()
        )

        async let firstResult = captureRequestError(executor, path: "/demo")
        async let secondResult = captureRequestError(executor, path: "/demo")
        let results = await [firstResult, secondResult]

        #expect(refreshService.receivedTokens == ["refresh-token"])
        #expect(results.count == 2)
        #expect(results.allSatisfy { $0 == "refresh failed" })
    }

    @Test
    func requestData_concurrent402_refreshTimeout_failsAllWaiters() async {
        let refreshService = ConfigurableMockTokenRefreshService(behavior: .never)
        let client = MockNetworkClient(responses: [
            .success(jsonResponse(statusCode: 200, body: #"{"code":402,"msg":"refresh"}"#)),
            .success(jsonResponse(statusCode: 200, body: #"{"code":402,"msg":"refresh"}"#))
        ])
        let coordinator = TokenRefreshCoordinator(
            tokenRefreshService: refreshService,
            timeoutNanoseconds: 50_000_000
        )
        let executor = NetworkExecutor(
            networkClient: client,
            credentialProvider: MockCredentialProvider(refreshToken: "refresh-token"),
            tokenRefreshCoordinator: coordinator,
            sessionInvalidationHandler: MockInvalidationHandler()
        )

        async let firstResult = captureRequestError(executor, path: "/demo")
        async let secondResult = captureRequestError(executor, path: "/demo")
        let results = await [firstResult, secondResult]

        #expect(refreshService.receivedTokens == ["refresh-token"])
        #expect(results.count == 2)
        #expect(results.allSatisfy { $0 == "Token refresh timed out." })
    }

    @Test
    func requestData_concurrentDifferentTargets_retryAndReturnOwnResponses() async throws {
        let refreshService = ConfigurableMockTokenRefreshService(behavior: .success)
        let client = PathAwareMockNetworkClient()
        let executor = NetworkExecutor(
            networkClient: client,
            credentialProvider: MockCredentialProvider(refreshToken: "refresh-token"),
            tokenRefreshCoordinator: TokenRefreshCoordinator(tokenRefreshService: refreshService),
            sessionInvalidationHandler: MockInvalidationHandler()
        )

        async let firstData = executor.requestData(MockTarget(path: "/history"))
        async let secondData = executor.requestData(MockTarget(path: "/template"))
        let (historyData, templateData) = try await (firstData, secondData)

        let historyJSON = try #require(JSONSerialization.jsonObject(with: historyData) as? [String: Any])
        let templateJSON = try #require(JSONSerialization.jsonObject(with: templateData) as? [String: Any])

        #expect(refreshService.receivedTokens == ["refresh-token"])
        #expect(historyJSON["msg"] as? String == "/history-ok")
        #expect(templateJSON["msg"] as? String == "/template-ok")
    }
}

private struct MockTarget: CustomTargetType {
    let baseURL: URL = URL(string: "https://example.com")!
    let path: String
    let method: Networking.Method = .post
    let parameters: [String : Any] = [:]
    let task: Task = .requestPlain
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

private final class MockTokenRefreshService: @unchecked Sendable, TokenRefreshService {
    private(set) var receivedTokens: [String] = []

    func refreshToken(_ token: String, completion: @escaping (Bool, String?) -> Void) -> Cancellable? {
        receivedTokens.append(token)
        completion(true, nil)
        return nil
    }
}

private final class MockInvalidationHandler: @unchecked Sendable, SessionInvalidationHandler {
    private(set) var lastMessage: String?

    func invalidateSession(message: String?) {
        lastMessage = message
    }
}

private final class ConfigurableMockTokenRefreshService: @unchecked Sendable, TokenRefreshService {
    enum Behavior {
        case success
        case failure(String)
        case never
    }

    private let behavior: Behavior
    private(set) var receivedTokens: [String] = []

    init(behavior: Behavior) {
        self.behavior = behavior
    }

    func refreshToken(_ token: String, completion: @escaping (Bool, String?) -> Void) -> Cancellable? {
        receivedTokens.append(token)
        switch behavior {
        case .success:
            completion(true, nil)
        case .failure(let message):
            completion(false, message)
        case .never:
            break
        }
        return nil
    }
}

private actor PathAwareMockNetworkClient: NetworkClient {
    private var attemptsByPath: [String: Int] = [:]

    func send(_ request: URLRequest) async throws -> NetworkClientResponse {
        let path = request.url?.path ?? "/unknown"
        let attempt = (attemptsByPath[path] ?? 0) + 1
        attemptsByPath[path] = attempt

        if attempt == 1 {
            return jsonResponse(
                statusCode: 200,
                body: #"{"code":402,"msg":"refresh"}"#,
                path: path
            )
        }

        return jsonResponse(
            statusCode: 200,
            body: #"{"code":200,"msg":"\#(path)-ok","data":{"path":"\#(path)"}}"#,
            path: path
        )
    }
}

private func captureRequestError(_ executor: NetworkExecutor, path: String) async -> String? {
    do {
        _ = try await executor.requestData(MockTarget(path: path))
        return nil
    } catch {
        return error.localizedDescription
    }
}

private func jsonResponse(statusCode: Int, body: String, path: String = "/demo") -> NetworkClientResponse {
    let url = URL(string: "https://example.com\(path)")!
    let response = HTTPURLResponse(
        url: url,
        statusCode: statusCode,
        httpVersion: nil,
        headerFields: ["Content-Type": "application/json"]
    )!
    return NetworkClientResponse(data: Data(body.utf8), response: response)
}
