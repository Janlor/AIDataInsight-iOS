import Observation
import SwiftUI

public struct LoginViewState: Equatable, Sendable {
    public var account: String
    public var password: String
    public var acceptedPrivacy: Bool

    public init(account: String = "demo", password: String = "demo@123", acceptedPrivacy: Bool = false) {
        self.account = account
        self.password = password
        self.acceptedPrivacy = acceptedPrivacy
    }
}

@MainActor
@Observable
public final class LoginStore {
    public private(set) var state: LoginViewState

    public init(state: LoginViewState = LoginViewState()) {
        self.state = state
    }

    public func updateAccount(_ account: String) {
        state.account = account
    }

    public func updatePassword(_ password: String) {
        state.password = password
    }

    public func setPrivacyAccepted(_ accepted: Bool) {
        state.acceptedPrivacy = accepted
    }
}

public struct LoginScreen: View {
    @Bindable private var store: LoginStore

    public init(store: LoginStore) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 16) {
            Text("AI数据分析助手")
                .font(.largeTitle.bold())
            TextField("账号", text: Binding(
                get: { store.state.account },
                set: { store.updateAccount($0) }
            ))
                .textFieldStyle(.roundedBorder)
            SecureField("密码", text: Binding(
                get: { store.state.password },
                set: { store.updatePassword($0) }
            ))
                .textFieldStyle(.roundedBorder)
            Toggle("我已阅读并同意隐私政策", isOn: Binding(
                get: { store.state.acceptedPrivacy },
                set: { store.setPrivacyAccepted($0) }
            ))
            Button("登录") {}
                .buttonStyle(.borderedProminent)
        }
        .padding(24)
        .frame(maxWidth: 420)
    }
}
