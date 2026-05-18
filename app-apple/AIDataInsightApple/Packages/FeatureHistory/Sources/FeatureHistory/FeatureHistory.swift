import Observation
import SwiftUI

public struct HistoryConversationViewState: Identifiable, Equatable, Sendable {
    public let id: String
    public let title: String

    public init(id: String, title: String) {
        self.id = id
        self.title = title
    }
}

@MainActor
@Observable
public final class HistoryStore {
    public private(set) var conversations: [HistoryConversationViewState]

    public init(conversations: [HistoryConversationViewState] = []) {
        self.conversations = conversations
    }

    public func delete(id: String) {
        conversations.removeAll { $0.id == id }
    }
}

public struct HistorySidebar: View {
    public let conversations: [HistoryConversationViewState]

    public init(conversations: [HistoryConversationViewState]) {
        self.conversations = conversations
    }

    public var body: some View {
        List(conversations) { conversation in
            Text(conversation.title)
        }
        .navigationTitle("历史记录")
    }
}
