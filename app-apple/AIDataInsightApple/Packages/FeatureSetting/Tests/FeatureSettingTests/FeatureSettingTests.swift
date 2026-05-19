import Testing
import AppContracts
@testable import FeatureSetting

@MainActor
@Test func settingStoreUsesDefaultSnapshot() {
    let store = SettingStore()
    #expect(store.state.title == "设置")
    #expect(store.state.sections.map(\.kind) == [.account, .about, .logout])
    #expect(store.state.sections.first?.rows.map(\.kind) == [.nickname, .username, .phone])
}

@Test func settingStateBuildsPrivacyAndLogoutRowsFromContractSnapshot() {
    let snapshot = SettingSnapshotContract(
        accountInfo: SettingAccountInfoContract(nickname: nil, username: "demo", phone: nil),
        capability: SettingCapabilityContract(canUpdatePassword: false, canOpenPrivacy: true, canLogout: true),
        appVersion: "1.0"
    )
    let sections = SettingViewState.sections(from: snapshot)

    #expect(sections[1].rows.contains { $0.kind == .privacy && $0.action == .openPrivacy })
    #expect(sections[2].rows.first?.destructive == true)
}
