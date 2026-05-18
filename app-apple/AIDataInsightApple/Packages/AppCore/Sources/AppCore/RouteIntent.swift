public enum RouteIntent: Equatable, Sendable {
    case login
    case workspace
    case privacy
    case settings
    case historyDetail(id: String)
    case newChat
}
