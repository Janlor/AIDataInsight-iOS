//
//  AppCommands.swift
//  AIDataInsightApple
//
//  Created by Codex on 5/19/26.
//

import Foundation
import SwiftUI

struct AppCommands: Commands {
    var body: some Commands {
        CommandMenu("AIDataInsight") {
            Button("New Chat") {
                NotificationCenter.default.post(name: .startNewChat, object: nil)
            }
            .keyboardShortcut("n", modifiers: [.command])
        }
    }
}

extension Notification.Name {
    static let startNewChat = Notification.Name("AIDataInsightApple.startNewChat")
}
