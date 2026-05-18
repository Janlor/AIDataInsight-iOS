import Testing
@testable import FeaturePrivacy

@Test func privacyPolicyProvidesDefaultTitle() {
    #expect(PrivacyPolicyState().title == "隐私政策")
}

