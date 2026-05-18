import SwiftUI

public struct TokenizedBackground: ViewModifier {
    public init() {}

    public func body(content: Content) -> some View {
        content
            .background(AppColor.Background.primary.color)
            .foregroundStyle(AppColor.Label.primary.color)
    }
}

public extension View {
    func tokenizedBackground() -> some View {
        modifier(TokenizedBackground())
    }
}
