//
//  RootView.swift
//  AIDataInsightApple
//
//  Created by Codex on 5/19/26.
//

import AppDesignSystem
import Foundation
import FeatureAIChat
import FeatureHistory
import FeatureLogin
import FeaturePrivacy
import FeatureSetting
import SwiftData
import SwiftUI

struct RootView: View {
    @Bindable var environment: AppRuntimeEnvironment
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
#if os(macOS)
    @Environment(\.openSettings) private var openSettings
#endif
    @State private var settingPath: [RootRoute] = []
    @State private var showsSetting = false
    @State private var showsHistory = false
    @State private var showsPrivacy = false
    @State private var showsLogoutConfirmation = false

    var body: some View {
        Group {
            if environment.loginStore.state.hasResolvedLaunchSession == false {
                launchResolvingView
            } else if environment.loginStore.state.isAuthenticated {
                if horizontalSizeClass == .compact {
                    compactWorkspace
                } else {
                    splitWorkspace
                }
            } else {
                NavigationStack {
                    LoginScreen(store: environment.loginStore, privacyDestination: AnyView(PrivacyScreen()))
                }
            }
        }
        .tokenizedBackground()
        .modelContainer(environment.modelContainer)
        .desktopContentSize()
        .task {
            await environment.loginStore.resolveLaunchSession()
        }
        .onReceive(NotificationCenter.default.publisher(for: .startNewChat)) { _ in
            environment.historyStore.clearSelection()
            environment.chatStore.startNewChat()
            showsHistory = false
        }
        .onReceive(NotificationCenter.default.publisher(for: .openPrivacyPolicy)) { _ in
            showsPrivacy = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .requestLogout)) { _ in
            showsLogoutConfirmation = true
        }
        .onChange(of: environment.settingStore.state.didLogout) { _, didLogout in
            guard didLogout else {
                return
            }
            environment.loginStore.markLoggedOut()
            environment.settingStore.consumeLogoutSignal()
            settingPath.removeAll()
            showsSetting = false
            showsHistory = false
            showsPrivacy = false
            showsLogoutConfirmation = false
        }
        .sheet(isPresented: $showsPrivacy) {
            NavigationStack {
                PrivacyScreen()
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("关闭") {
                                showsPrivacy = false
                            }
                        }
                    }
            }
            .frame(minWidth: 520, minHeight: 620)
        }
        .sheet(isPresented: $showsLogoutConfirmation) {
            LogoutConfirmationSheet(
                isLoggingOut: environment.settingStore.state.isLoggingOut,
                onCancel: {
                    showsLogoutConfirmation = false
                },
                onConfirm: {
                    Task {
                        await environment.settingStore.logout()
                    }
                }
            )
        }
    }

    private var launchResolvingView: some View {
        AppColor.Background.secondary.color
            .ignoresSafeArea()
            .accessibilityIdentifier("launch-session-resolving")
    }

    private var splitWorkspace: some View {
                NavigationSplitView {
                    HistorySidebar(
                        store: environment.historyStore,
                        onNewChat: {
                            environment.chatStore.startNewChat()
                        },
                        onSelect: { historyID in
                            Task {
                                await environment.chatStore.loadHistory(historyID: historyID)
                            }
                        },
                        onDeletedSelected: {
                            environment.chatStore.startNewChat()
                        },
                        onOpenSetting: {
#if os(macOS)
                            openSettings()
#else
                            showsSetting = true
#endif
                        },
                        onOpenPrivacy: {
                            showsPrivacy = true
                        },
                        onLogout: {
                            showsLogoutConfirmation = true
                        }
                    )
                } detail: {
                    AIChatScreen(store: environment.chatStore)
                        .toolbar {
                            ToolbarItem {
                                Button("New Chat", systemImage: "square.and.pencil") {
                                    environment.historyStore.clearSelection()
                                    environment.chatStore.startNewChat()
                                }
                                .accessibilityIdentifier("toolbar-new-chat-button")
                            }
#if !os(macOS)
                            ToolbarItem {
                                Button("Settings", systemImage: "gearshape") {
                                    showsSetting = true
                                }
                                .accessibilityIdentifier("toolbar-settings-button")
                            }
#endif
                        }
                }
#if !os(macOS)
                .sheet(isPresented: $showsSetting) {
                    settingView
                        .frame(minWidth: 500, minHeight: 600)
                }
#endif
    }

    private var compactWorkspace: some View {
        NavigationStack {
            AIChatScreen(store: environment.chatStore)
                .toolbar {
                    ToolbarItem {
                        Button("History", systemImage: "sidebar.left") {
                            showsHistory = true
                        }
                    }
#if !os(macOS)
                    ToolbarItem {
                        Button("Settings", systemImage: "gearshape") {
                            showsSetting = true
                        }
                        .accessibilityIdentifier("toolbar-settings-button")
                    }
#endif
                }
        }
        .sheet(isPresented: $showsHistory) {
            NavigationStack {
                HistorySidebar(
                    store: environment.historyStore,
                    onNewChat: {
                        environment.historyStore.clearSelection()
                        environment.chatStore.startNewChat()
                        showsHistory = false
                    },
                    onSelect: { historyID in
                        Task {
                            await environment.chatStore.loadHistory(historyID: historyID)
                            showsHistory = false
                        }
                    },
                    onDeletedSelected: {
                        environment.chatStore.startNewChat()
                    },
                    onOpenSetting: {
                        showsHistory = false
                        showsSetting = true
                    },
                    onOpenPrivacy: {
                        showsHistory = false
                        showsPrivacy = true
                    },
                    onLogout: {
                        showsHistory = false
                        showsLogoutConfirmation = true
                    }
                )
                .toolbar {
                    ToolbarItem {
                        Button("关闭") {
                            showsHistory = false
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showsSetting) {
            settingView
        }
    }

    private var settingView: some View {
        NavigationStack(path: $settingPath) {
            SettingScreen(
                store: environment.settingStore,
                onOpenPrivacy: {
                    settingPath.append(.privacy)
                }
            )
            .navigationDestination(for: RootRoute.self) { route in
                switch route {
                case .privacy:
                    PrivacyScreen()
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") {
                        showsSetting = false
                    }
                }
            }
        }
    }
}

#Preview {
    RootView(environment: AppRuntimeEnvironment(usePreviewRepositories: true))
}

private enum RootRoute: Hashable {
    case privacy
}

private struct LogoutConfirmationSheet: View {
    let isLoggingOut: Bool
    let onCancel: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("退出登录")
                .font(.headline)
            Text("退出后需要重新登录才能继续使用。")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack {
                Spacer()
                Button("取消") {
                    onCancel()
                }
                .keyboardShortcut(.cancelAction)

                Button(isLoggingOut ? "退出中..." : "退出登录", role: .destructive) {
                    onConfirm()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(isLoggingOut)
                .accessibilityIdentifier("logout-confirm-button")
            }
        }
        .padding(24)
        .frame(width: 360)
    }
}

private extension View {
    @ViewBuilder
    func desktopContentSize() -> some View {
#if os(macOS)
        frame(minWidth: 1040, minHeight: 680)
#else
        self
#endif
    }
}
