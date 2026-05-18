//
//  AppEnvironment.swift
//  AIDataInsightApple
//
//  Created by Codex on 5/19/26.
//

import AppCore
import FeatureAIChat
import FeatureHistory
import FeatureLogin
import FeatureSetting
import Observation

@MainActor
@Observable
final class AppRuntimeEnvironment {
    let appEnvironment: AppEnvironment
    let loginStore: LoginStore
    let chatStore: AIChatStore
    let historyStore: HistoryStore
    let settingStore: SettingStore

    init(
        appEnvironment: AppEnvironment = .mock,
        loginStore: LoginStore = LoginStore(),
        chatStore: AIChatStore = AIChatStore(),
        historyStore: HistoryStore = HistoryStore(conversations: [
            HistoryConversationViewState(id: "welcome", title: "欢迎使用 AI 数据分析助手"),
        ]),
        settingStore: SettingStore = SettingStore()
    ) {
        self.appEnvironment = appEnvironment
        self.loginStore = loginStore
        self.chatStore = chatStore
        self.historyStore = historyStore
        self.settingStore = settingStore
    }
}
