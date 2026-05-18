import Testing
@testable import FeatureHistory

@MainActor
@Test func historyStoreDeletesConversation() {
    let store = HistoryStore(conversations: [
        HistoryConversationViewState(id: "1", title: "A"),
        HistoryConversationViewState(id: "2", title: "B"),
    ])

    store.delete(id: "1")
    #expect(store.conversations.map(\.id) == ["2"])
}

