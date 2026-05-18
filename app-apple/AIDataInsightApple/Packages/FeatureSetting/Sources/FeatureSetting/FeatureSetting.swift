import Observation
import SwiftUI

public struct SettingViewState: Equatable, Sendable {
    public var displayName: String
    public var appVersion: String

    public init(displayName: String = "Janlor Lee", appVersion: String = "1.0") {
        self.displayName = displayName
        self.appVersion = appVersion
    }
}

@MainActor
@Observable
public final class SettingStore {
    public private(set) var state: SettingViewState

    public init(state: SettingViewState = SettingViewState()) {
        self.state = state
    }
}

public struct SettingScreen: View {
    public let state: SettingViewState

    public init(state: SettingViewState) {
        self.state = state
    }

    public var body: some View {
        Form {
            Section("账户") {
                LabeledContent("昵称", value: state.displayName)
            }
            Section("关于") {
                LabeledContent("App版本", value: state.appVersion)
            }
        }
        .navigationTitle("设置")
    }
}
