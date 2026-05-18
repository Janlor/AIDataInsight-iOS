import Foundation
import Observation
import SwiftUI

public struct ChatMessageViewState: Identifiable, Equatable, Sendable {
    public enum Role: Equatable, Sendable {
        case user
        case assistant
    }

    public let id: String
    public let role: Role
    public var text: String

    public init(id: String, role: Role, text: String) {
        self.id = id
        self.role = role
        self.text = text
    }
}

@MainActor
@Observable
public final class AIChatStore {
    public private(set) var messages: [ChatMessageViewState]

    public init(messages: [ChatMessageViewState] = []) {
        self.messages = messages
    }

    public func startNewChat() {
        messages.removeAll()
    }

    public func appendUserMessage(_ text: String) {
        messages.append(ChatMessageViewState(id: UUID().uuidString, role: .user, text: text))
    }
}

public struct AIChatScreen: View {
    @Bindable private var store: AIChatStore

    public init(store: AIChatStore) {
        self.store = store
    }

    public var body: some View {
        VStack {
            if store.messages.isEmpty {
                Text("今天想分析什么？")
                    .font(.title.bold())
                    .accessibilityIdentifier("ai-chat-empty-title")
            } else {
                List(store.messages) { message in
                    Text(message.text)
                }
            }
        }
        .navigationTitle("AI数据分析助手")
    }
}
