import Foundation
import Testing
@testable import Networking
import AccountProtocol

struct NetworkDependenciesTests {
    @Test
    func sessionInvalidationHandler_postsLogoutNotificationWithMessage() async {
        let recorder = NotificationRecorder(name: .logoutSucceed)
        let handler = DefaultSessionInvalidationHandler()

        handler.invalidateSession(message: "expired")

        let userInfo = await recorder.waitForNotification()
        #expect(userInfo?["msg"] as? String == "expired")
    }

    @Test
    func networkDependencies_canSwapProviders() {
        let originalCredentialProvider = NetworkDependencies.credentialProvider
        let originalTokenRefreshService = NetworkDependencies.tokenRefreshService
        let originalSessionInvalidationHandler = NetworkDependencies.sessionInvalidationHandler
        defer {
            NetworkDependencies.credentialProvider = originalCredentialProvider
            NetworkDependencies.tokenRefreshService = originalTokenRefreshService
            NetworkDependencies.sessionInvalidationHandler = originalSessionInvalidationHandler
        }

        let credentialProvider = MockCredentialProvider(
            accessToken: "token-1",
            refreshToken: "refresh-1",
            orgId: 7
        )
        let tokenRefreshService = MockTokenRefreshService()
        let invalidationHandler = MockSessionInvalidationHandler()

        NetworkDependencies.credentialProvider = credentialProvider
        NetworkDependencies.tokenRefreshService = tokenRefreshService
        NetworkDependencies.sessionInvalidationHandler = invalidationHandler

        #expect((NetworkDependencies.credentialProvider as? MockCredentialProvider)?.accessToken == "token-1")
        #expect((NetworkDependencies.credentialProvider as? MockCredentialProvider)?.refreshToken == "refresh-1")
        #expect((NetworkDependencies.credentialProvider as? MockCredentialProvider)?.orgId == 7)
        #expect(NetworkDependencies.tokenRefreshService is MockTokenRefreshService)
        #expect(NetworkDependencies.sessionInvalidationHandler is MockSessionInvalidationHandler)
    }
}

private struct MockCredentialProvider: NetworkCredentialProvider {
    let accessToken: String?
    let refreshToken: String?
    let orgId: Int?
}

private struct MockTokenRefreshService: TokenRefreshService {
    func refreshToken(_ token: String, completion: @escaping (Bool, String?) -> Void) -> Cancellable? {
        completion(true, nil)
        return nil
    }
}

private final class MockSessionInvalidationHandler: @unchecked Sendable, SessionInvalidationHandler {
    private(set) var lastMessage: String?

    func invalidateSession(message: String?) {
        lastMessage = message
    }
}

private actor NotificationRecorder {
    private let name: Notification.Name
    private var continuation: CheckedContinuation<[AnyHashable: Any]?, Never>?
    private var token: NSObjectProtocol?

    init(name: Notification.Name) {
        self.name = name
        self.token = NotificationCenter.default.addObserver(
            forName: name,
            object: nil,
            queue: nil
        ) { [weak self] notification in
            guard let self else { return }
            _Concurrency.Task {
                await self.resume(with: notification.userInfo)
            }
        }
    }

    func waitForNotification() async -> [AnyHashable: Any]? {
        await withCheckedContinuation { continuation in
            self.continuation = continuation
        }
    }

    private func resume(with userInfo: [AnyHashable: Any]?) {
        continuation?.resume(returning: userInfo)
        continuation = nil
    }

    deinit {
        if let token {
            NotificationCenter.default.removeObserver(token)
        }
    }
}
