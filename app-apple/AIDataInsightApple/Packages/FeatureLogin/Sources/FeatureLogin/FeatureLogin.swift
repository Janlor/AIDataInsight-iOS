import AppAccount
import AppCore
import Observation
import SwiftUI

public struct LoginViewState: Equatable, Sendable {
    public var account: String
    public var password: String
    public var acceptedPrivacy: Bool
    public var isLoading: Bool
    public var errorMessage: String?
    public var isAuthenticated: Bool

    public init(
        account: String = "demo",
        password: String = "demo@123",
        acceptedPrivacy: Bool = false,
        isLoading: Bool = false,
        errorMessage: String? = nil,
        isAuthenticated: Bool = false
    ) {
        self.account = account
        self.password = password
        self.acceptedPrivacy = acceptedPrivacy
        self.isLoading = isLoading
        self.errorMessage = errorMessage
        self.isAuthenticated = isAuthenticated
    }
}

@MainActor
@Observable
public final class LoginStore {
    public private(set) var state: LoginViewState
    private let accountService: AccountServicing

    public init(
        state: LoginViewState = LoginViewState(),
        accountService: AccountServicing = PreviewAccountService()
    ) {
        self.state = state
        self.accountService = accountService
    }

    public func updateAccount(_ account: String) {
        state.account = account
        state.errorMessage = nil
    }

    public func updatePassword(_ password: String) {
        state.password = password
        state.errorMessage = nil
    }

    public func setPrivacyAccepted(_ accepted: Bool) {
        state.acceptedPrivacy = accepted
        state.errorMessage = nil
    }

    public func resolveLaunchSession() async {
        do {
            state.isAuthenticated = try await accountService.resolveLaunchSession()?.isLogin == true
        } catch {
            state.isAuthenticated = false
        }
    }

    public func login() async {
        guard state.acceptedPrivacy else {
            state.errorMessage = "请先阅读并同意隐私政策"
            return
        }
        guard state.account.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false,
              state.password.isEmpty == false
        else {
            state.errorMessage = "请输入账号和密码"
            return
        }

        state.isLoading = true
        state.errorMessage = nil
        do {
            _ = try await accountService.login(name: state.account, password: state.password)
            state.isAuthenticated = true
        } catch let error as AppError {
            state.errorMessage = error.messageForDisplay
        } catch {
            state.errorMessage = "登录失败，请稍后重试"
        }
        state.isLoading = false
    }

    public func logout() async {
        state.isLoading = true
        do {
            try await accountService.logout()
            state.isAuthenticated = false
        } catch {
            state.errorMessage = "退出登录失败，请稍后重试"
        }
        state.isLoading = false
    }

    public func markLoggedOut() {
        state.isAuthenticated = false
    }
}

public struct LoginScreen: View {
    @Bindable private var store: LoginStore
    private let privacyDestination: AnyView?

    public init(store: LoginStore, privacyDestination: AnyView? = nil) {
        self.store = store
        self.privacyDestination = privacyDestination
    }

    public var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.10), Color.teal.opacity(0.08), Color.clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 28) {
                VStack(spacing: 10) {
                    Image(systemName: "chart.xyaxis.line")
                        .font(.system(size: 46, weight: .semibold))
                        .foregroundStyle(.blue)
                        .frame(width: 72, height: 72)
                        .background(.blue.opacity(0.10), in: Circle())
                    Text("AI数据分析助手")
                        .font(.largeTitle.bold())
                    Text("用自然语言提问，快速获得经营数据洞察")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 14) {
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

                    Toggle(isOn: Binding(
                        get: { store.state.acceptedPrivacy },
                        set: { store.setPrivacyAccepted($0) }
                    )) {
                        HStack(spacing: 4) {
                            Text("我已阅读并同意")
                            if let privacyDestination {
                                NavigationLink("隐私政策") {
                                    privacyDestination
                                }
                            } else {
                                Text("隐私政策")
                            }
                        }
                    }

                    if let errorMessage = store.state.errorMessage {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.footnote)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button {
                        Task {
                            await store.login()
                        }
                    } label: {
                        HStack {
                            if store.state.isLoading {
                                ProgressView()
                                    .controlSize(.small)
                            }
                            Text(store.state.isLoading ? "登录中..." : "登录")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .keyboardShortcut(.return, modifiers: [])
                    .disabled(store.state.isLoading)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                .padding(24)
                .frame(width: 420)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary.opacity(0.20))
                }

                Text("Demo 账号：demo / demo@123")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

public struct PreviewAccountService: AccountServicing {
    public init() {}

    public func resolveLaunchSession() async throws -> AccountSession? {
        nil
    }

    public func login(name: String, password: String) async throws -> AccountSession {
        AccountSession(accessToken: "preview-access", refreshToken: "preview-refresh", orgID: "0", username: name)
    }

    public func logout() async throws {}
}

private extension AppError {
    var messageForDisplay: String {
        switch kind {
        case .server(_, let message) where message.isEmpty == false:
            message
        case .sessionInvalid:
            "登录状态已失效，请重新登录"
        case .transport:
            "网络连接失败，请稍后重试"
        default:
            "登录失败，请稍后重试"
        }
    }
}
