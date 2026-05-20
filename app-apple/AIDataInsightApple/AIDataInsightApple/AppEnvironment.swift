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
        chatStore: AIChatStore? = nil,
        historyStore: HistoryStore? = nil,
        settingStore: SettingStore? = nil,
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
        let accountService: AccountServicing
        let aiChatRepository: AIChatRepository
        let historyRepository: HistoryRepository

        if appEnvironment == .mock {
            accountService = FeatureLogin.PreviewAccountService()
            aiChatRepository = PreviewAIChatRepository()
            historyRepository = PreviewHistoryRepository()
        } else {
            accountService = AccountService(client: client, sessionManager: resolvedSessionManager)
            aiChatRepository = RemoteAIChatRepository(client: client, streamer: client)
            historyRepository = RemoteHistoryRepository(client: client)
        }

        self.loginStore = loginStore ?? LoginStore(accountService: accountService)
        self.chatStore = chatStore ?? AIChatStore(repository: aiChatRepository)
        self.historyStore = historyStore ?? HistoryStore(repository: historyRepository)
        self.settingStore = settingStore ?? SettingStore(accountService: accountService)
    }

    private static func makeModelContainer() -> ModelContainer {
        do {
            return try AppModelContainerFactory.make()
        } catch {
            fatalError("Failed to create SwiftData model container: \(error)")
        }
    }
}
