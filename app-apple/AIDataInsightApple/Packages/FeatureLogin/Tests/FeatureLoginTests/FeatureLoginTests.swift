import Testing
@testable import FeatureLogin

@MainActor
@Test func loginStoreUpdatesInputState() {
    let store = LoginStore()
    store.updateAccount("janlor")
    store.updatePassword("secret")
    store.setPrivacyAccepted(true)

    #expect(store.state.account == "janlor")
    #expect(store.state.password == "secret")
    #expect(store.state.acceptedPrivacy)
}

