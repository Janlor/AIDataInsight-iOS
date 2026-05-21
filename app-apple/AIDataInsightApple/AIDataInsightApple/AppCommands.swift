//
//  AppCommands.swift
//  AIDataInsightApple
//
//  Created by Codex on 5/19/26.
//

import Foundation
import SwiftUI

struct AppCommands: Commands {
#if os(macOS)
    @Environment(\.openSettings) private var openSettings
#endif

    var body: some Commands {
        CommandMenu("AIDataInsight") {
            Button("New Chat") {
                NotificationCenter.default.post(name: .startNewChat, object: nil)
            }
            .keyboardShortcut("n", modifiers: [.command])
        }
#if os(macOS)
        CommandMenu("Account") {
            Button("Settings...") {
                openSettings()
            }
            .keyboardShortcut(",", modifiers: [.command])

            Button("Privacy Policy") {
                NotificationCenter.default.post(name: .openPrivacyPolicy, object: nil)
            }

            Divider()

            Button("Log Out") {
                NotificationCenter.default.post(name: .requestLogout, object: nil)
            }
            .keyboardShortcut("l", modifiers: [.command, .shift])
        }
#endif
    }
}

extension Notification.Name {
    static let startNewChat = Notification.Name("AIDataInsightApple.startNewChat")
    static let openPrivacyPolicy = Notification.Name("AIDataInsightApple.openPrivacyPolicy")
    static let requestLogout = Notification.Name("AIDataInsightApple.requestLogout")
}
