import Testing
@testable import FeatureAIChat

@MainActor
@Test func chatStoreStartsNewChat() {
    let store = AIChatStore()
    store.appendUserMessage("hello")
    #expect(store.messages.count == 1)

    store.startNewChat()
    #expect(store.messages.isEmpty)
}

