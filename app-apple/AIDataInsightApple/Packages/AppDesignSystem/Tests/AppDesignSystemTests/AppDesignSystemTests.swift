import Testing
@testable import AppDesignSystem

@Test func spacingTokensAreStable() {
    #expect(AppSpacing.small == 8)
    #expect(AppSpacing.medium == 16)
    #expect(AppSpacing.large == 24)
}

@Test func accentPrimaryMatchesContractToken() {
    #expect(AppColor.Accent.primary.lightHex == "#2F7BFF")
    #expect(AppColor.Accent.primary.darkHex == "#4C8DFF")
}

@Test func chartPaletteOrderMatchesContractToken() {
    #expect(AppChartPalette.order == ["blue", "cyan", "mint", "green", "purple", "orange", "coral"])
}
