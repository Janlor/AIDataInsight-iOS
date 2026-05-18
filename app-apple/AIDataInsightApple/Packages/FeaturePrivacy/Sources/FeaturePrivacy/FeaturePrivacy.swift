import SwiftUI

public struct PrivacyPolicyState: Equatable, Sendable {
    public let title: String
    public let body: String

    public init(title: String = "隐私政策", body: String = "AIDataInsight 仅在必要时处理账号与数据分析请求。") {
        self.title = title
        self.body = body
    }
}

public struct PrivacyScreen: View {
    public let state: PrivacyPolicyState

    public init(state: PrivacyPolicyState = PrivacyPolicyState()) {
        self.state = state
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(state.title)
                    .font(.largeTitle.bold())
                Text(state.body)
            }
            .padding(24)
            .frame(maxWidth: 760, alignment: .leading)
        }
        .navigationTitle(state.title)
    }
}
