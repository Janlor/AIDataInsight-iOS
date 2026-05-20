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
    @State private var settingPath: [RootRoute] = []
    @State private var showsSetting = false

    var body: some View {
        Group {
            if environment.loginStore.state.isAuthenticated {
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
                                Button("Settings", systemImage: "gearshape") {
                                    showsSetting = true
                                }
                            }
                        }
                }
                .sheet(isPresented: $showsSetting) {
                    settingView
                        .frame(minWidth: 500, minHeight: 600)
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
        }
        .onChange(of: environment.settingStore.state.didLogout) { _, didLogout in
            guard didLogout else {
                return
            }
            environment.loginStore.markLoggedOut()
            environment.settingStore.consumeLogoutSignal()
            settingPath.removeAll()
            showsSetting = false
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
        }
    }
}

#Preview {
    RootView(environment: AppRuntimeEnvironment())
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
