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

    var body: some View {
        Group {
            if environment.loginStore.state.isAuthenticated {
                NavigationSplitView {
                    HistorySidebar(conversations: environment.historyStore.conversations)
                        .toolbar {
                            ToolbarItem {
                                Button("New Chat", systemImage: "plus") {
                                    environment.chatStore.startNewChat()
                                }
                            }
                        }
                } content: {
                    AIChatScreen(store: environment.chatStore)
                } detail: {
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
            } else {
                NavigationStack {
                    LoginScreen(store: environment.loginStore, privacyDestination: AnyView(PrivacyScreen()))
                }
            }
        }
        .tokenizedBackground()
        .modelContainer(environment.modelContainer)
        .task {
            await environment.loginStore.resolveLaunchSession()
        }
        .onReceive(NotificationCenter.default.publisher(for: .startNewChat)) { _ in
            environment.chatStore.startNewChat()
        }
        .onChange(of: environment.settingStore.state.didLogout) { _, didLogout in
            guard didLogout else {
                return
            }
            environment.loginStore.markLoggedOut()
            environment.settingStore.consumeLogoutSignal()
            settingPath.removeAll()
        }
    }
}

#Preview {
    RootView(environment: AppRuntimeEnvironment())
}

private enum RootRoute: Hashable {
    case privacy
}
