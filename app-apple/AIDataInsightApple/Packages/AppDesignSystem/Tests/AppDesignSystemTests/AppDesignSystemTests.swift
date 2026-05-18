import Testing
@testable import AppDesignSystem

@Test func spacingTokensAreStable() {
    #expect(AppSpacing.small == 8)
    #expect(AppSpacing.medium == 16)
    #expect(AppSpacing.large == 24)
}

