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
    @State private var settingPath: [RootRoute] = []
    @State private var showsSetting = false
    @State private var showsHistory = false

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
        .onChange(of: environment.settingStore.state.didLogout) { _, didLogout in
            guard didLogout else {
                return
            }
            environment.loginStore.markLoggedOut()
            environment.settingStore.consumeLogoutSignal()
            settingPath.removeAll()
            showsSetting = false
            showsHistory = false
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
                            showsSetting = true
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
                            ToolbarItem {
                                Button("Settings", systemImage: "gearshape") {
                                    showsSetting = true
                                }
                                .accessibilityIdentifier("toolbar-settings-button")
                            }
                        }
                }
                .sheet(isPresented: $showsSetting) {
                    settingView
                        .frame(minWidth: 500, minHeight: 600)
                }
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
                    ToolbarItem {
                        Button("Settings", systemImage: "gearshape") {
                            showsSetting = true
                        }
                        .accessibilityIdentifier("toolbar-settings-button")
                    }
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
