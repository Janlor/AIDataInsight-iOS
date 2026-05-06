import Foundation
import Testing
@testable import Setting

@MainActor
struct SettingViewModelTests {
    @Test
    func reloadData_buildsSectionsFromSnapshot() {
        let repository = MockSettingRepository(
            snapshot: SettingSnapshot(
                accountInfo: SettingAccountInfo(
                    nickname: nil,
                    username: "demo",
                    phone: "13800138000"
                ),
                capability: SettingCapability(
                    canUpdatePassword: false,
                    canOpenPrivacy: true,
                    canLogout: true
                ),
                appVersion: "1.0.0 (100)"
            )
        )
        let viewModel = SettingViewModel(repository: repository)

        viewModel.reloadData()

        let unsetText = NSLocalizedString("未设置", bundle: .module, comment: "")

        #expect(viewModel.numberOfSections() == 3)
        #expect(viewModel.section(at: 0)?.items.count == 3)
        #expect(viewModel.section(at: 1)?.items.count == 2)
        #expect(viewModel.section(at: 2)?.items.count == 1)
        #expect(viewModel.item(at: IndexPath(row: 0, section: 0))?.detail == unsetText)
        if case .privacy? = viewModel.item(at: IndexPath(row: 0, section: 1))?.action {
        } else {
            Issue.record("Expected privacy action in section 1 row 0")
        }
        if case .logout? = viewModel.item(at: IndexPath(row: 0, section: 2))?.action {
        } else {
            Issue.record("Expected logout action in section 2 row 0")
        }
    }

    @Test
    func logout_whenRepositoryThrows_emitsErrorMessage() async {
        let repository = MockSettingRepository(
            snapshot: SettingSnapshot(
                accountInfo: SettingAccountInfo(nickname: nil, username: nil, phone: nil),
                capability: SettingCapability(canUpdatePassword: false, canOpenPrivacy: false, canLogout: false),
                appVersion: "-"
            ),
            logoutError: MockError.logoutFailed
        )
        let viewModel = SettingViewModel(repository: repository)
        var receivedMessage: String?
        viewModel.onError = { receivedMessage = $0 }

        await viewModel.logout()

        #expect(receivedMessage == MockError.logoutFailed.localizedDescription)
    }
}

private struct MockSettingRepository: SettingRepository {
    let snapshot: SettingSnapshot
    var logoutError: Error?

    func loadSnapshot() -> SettingSnapshot {
        snapshot
    }

    func logout() async throws {
        if let logoutError {
            throw logoutError
        }
    }
}

private enum MockError: LocalizedError {
    case logoutFailed

    var errorDescription: String? {
        switch self {
        case .logoutFailed:
            return "logout failed"
        }
    }
}
