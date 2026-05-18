import Testing
@testable import FeatureSetting

@MainActor
@Test func settingStoreUsesDefaultSnapshot() {
    let store = SettingStore()
    #expect(store.state.displayName == "Janlor Lee")
    #expect(store.state.appVersion == "1.0")
}

