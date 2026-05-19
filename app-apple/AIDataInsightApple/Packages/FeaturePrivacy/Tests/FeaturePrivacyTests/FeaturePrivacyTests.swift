import Testing
import AppContracts
@testable import FeaturePrivacy

@Test func privacyPolicyProvidesDefaultTitle() {
    #expect(PrivacyPolicyState().title == "隐私政策")
}

@Test func privacyPolicyMapsContractSections() {
    let state = PrivacyPolicyState(contract: PrivacyPolicyContract.current)

    #expect(state.updatedAt == "2026-05-18")
    #expect(state.sections.count == PrivacyPolicyContract.current.sections.count)
    #expect(state.sections.first?.heading == "我们如何使用数据")
}
