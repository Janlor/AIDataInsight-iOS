import Foundation
import Testing
import PrivacyProtocol
@testable import Privacy

struct PrivacyPolicyViewModelTests {
    @Test
    func shouldShowPolicyAgreement_onlyReturnsTrueOnceWhenNotAgreed() {
        let repository = MockPrivacyRepository(isAgreed: false, url: "https://example.com/privacy")
        let viewModel = PrivacyPolicyViewModel(repository: repository)

        let first = viewModel.shouldShowPolicyAgreement()
        let second = viewModel.shouldShowPolicyAgreement()

        #expect(first == true)
        #expect(second == false)
    }

    @Test
    func agreeToLatestPolicy_savesAgreementAndPostsNotification() {
        let repository = MockPrivacyRepository(isAgreed: false, url: "https://example.com/privacy")
        let viewModel = PrivacyPolicyViewModel(repository: repository)
        let recorder = NotificationRecorder(name: .didAgreedAllPolicyAgreement)

        viewModel.agreeToLatestPolicy()

        #expect(repository.didSaveLatestAgreement == true)
        #expect(recorder.didReceiveNotification == true)
        recorder.stop()
    }

    @Test
    func makeAlertContent_usesRepositoryPrivacyURL() {
        let repository = MockPrivacyRepository(isAgreed: false, url: "https://example.com/privacy")
        let viewModel = PrivacyPolicyViewModel(repository: repository)

        let content = viewModel.makeAlertContent()

        #expect(content.linkTexts.values.contains("https://example.com/privacy"))
        #expect(viewModel.privacyPolicyURL() == "https://example.com/privacy")
    }
}

private final class MockPrivacyRepository: PrivacyRepository {
    let isAgreed: Bool
    let url: String
    var didSaveLatestAgreement = false

    init(isAgreed: Bool, url: String) {
        self.isAgreed = isAgreed
        self.url = url
    }

    func isAgreedAllPolicyAgreement() -> Bool {
        isAgreed
    }

    func saveLatestAgreement() {
        didSaveLatestAgreement = true
    }

    func privacyPolicyURL() -> String {
        url
    }
}

private final class NotificationRecorder {
    private(set) var didReceiveNotification = false
    private var token: NSObjectProtocol?

    init(name: Notification.Name) {
        token = NotificationCenter.default.addObserver(
            forName: name,
            object: nil,
            queue: nil
        ) { [weak self] _ in
            self?.didReceiveNotification = true
        }
    }

    func stop() {
        if let token {
            NotificationCenter.default.removeObserver(token)
        }
        token = nil
    }

    deinit {
        stop()
    }
}
