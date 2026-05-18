//
//  AppEnvironment.swift
//  AIDataInsightApple
//
//  Created by Codex on 5/19/26.
//

import AppAccount
import AppCore
import AppNetworking
import AppPersistence
import FeatureAIChat
import FeatureHistory
import FeatureLogin
import FeatureSetting
import Observation
import SwiftData

@MainActor
@Observable
final class AppRuntimeEnvironment {
    let appEnvironment: AppEnvironment
    let loginStore: LoginStore
    let chatStore: AIChatStore
    let historyStore: HistoryStore
    let settingStore: SettingStore
    let sessionManager: AccountSessionManager
    let modelContainer: ModelContainer

    init(
        appEnvironment: AppEnvironment = .mock,
        loginStore: LoginStore? = nil,
        chatStore: AIChatStore = AIChatStore(),
        historyStore: HistoryStore = HistoryStore(conversations: [
            HistoryConversationViewState(id: "welcome", title: "欢迎使用 AI 数据分析助手"),
        ]),
        settingStore: SettingStore = SettingStore(),
        sessionManager: AccountSessionManager? = nil,
        modelContainer: ModelContainer? = nil
    ) {
        self.appEnvironment = appEnvironment
        self.modelContainer = modelContainer ?? AppRuntimeEnvironment.makeModelContainer()
        let resolvedSessionManager = sessionManager ?? AccountSessionManager(store: KeychainSessionStore())
        self.sessionManager = resolvedSessionManager
        let client = URLSessionHTTPClient(
            environment: APIEnvironment.resolve(appEnvironment),
            sessionManager: resolvedSessionManager
        )
        let accountService = AccountService(client: client, sessionManager: resolvedSessionManager)
        self.loginStore = loginStore ?? LoginStore(accountService: accountService)
        self.chatStore = chatStore
        self.historyStore = historyStore
        self.settingStore = settingStore
    }

    private static func makeModelContainer() -> ModelContainer {
        do {
            return try AppModelContainerFactory.make()
        } catch {
            fatalError("Failed to create SwiftData model container: \(error)")
        }
    }
}
