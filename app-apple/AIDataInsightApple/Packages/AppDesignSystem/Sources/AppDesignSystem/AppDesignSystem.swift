import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public enum AppColor {
    public static let accentPrimary = Color(red: 47.0 / 255.0, green: 123.0 / 255.0, blue: 1.0)
    public static let backgroundPrimary = Color(light: .white, dark: Color(red: 11.0 / 255.0, green: 16.0 / 255.0, blue: 32.0 / 255.0))
    public static let backgroundSecondary = Color(light: Color(red: 244.0 / 255.0, green: 247.0 / 255.0, blue: 251.0 / 255.0), dark: Color(red: 21.0 / 255.0, green: 29.0 / 255.0, blue: 48.0 / 255.0))
    public static let labelPrimary = Color(light: Color(red: 17.0 / 255.0, green: 24.0 / 255.0, blue: 39.0 / 255.0), dark: Color(red: 249.0 / 255.0, green: 250.0 / 255.0, blue: 251.0 / 255.0))
}

public enum AppSpacing {
    public static let small: CGFloat = 8
    public static let medium: CGFloat = 16
    public static let large: CGFloat = 24
}

public enum AppRadius {
    public static let control: CGFloat = 10
    public static let panel: CGFloat = 16
}

public struct TokenizedBackground: ViewModifier {
    public init() {}

    public func body(content: Content) -> some View {
        content
            .background(AppColor.backgroundPrimary)
            .foregroundStyle(AppColor.labelPrimary)
    }
}

public extension View {
    func tokenizedBackground() -> some View {
        modifier(TokenizedBackground())
    }
}

private extension Color {
    init(light: Color, dark: Color) {
#if os(macOS)
        self.init(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(dark)
                : NSColor(light)
        })
#else
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(dark)
                : UIColor(light)
        })
#endif
    }
}
