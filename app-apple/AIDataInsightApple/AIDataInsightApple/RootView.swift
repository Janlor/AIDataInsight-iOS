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
                    SettingScreen(state: environment.settingStore.state)
                }
            } else {
                LoginScreen(store: environment.loginStore)
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
    }
}

#Preview {
    RootView(environment: AppRuntimeEnvironment())
}
