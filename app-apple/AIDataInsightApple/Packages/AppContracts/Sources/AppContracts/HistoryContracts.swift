public enum HistoryDetailTypeContract: String, Codable, Sendable {
    case question = "1"
    case answer = "2"
}

public enum HistoryContentTypeContract: String, Codable, Sendable {
    case ai = "1"
    case chart = "2"
}

public enum HistorySectionKindContract: String, Codable, CaseIterable, Sendable {
    case today
    case thisMonth
    case other
}

public struct HistoryDetailContract: Codable, Equatable, Sendable {
    public let id: Int?
    public let historyId: Int?
    public let type: HistoryDetailTypeContract?
    public let contentType: HistoryContentTypeContract?
    public let content: String?

    public init(id: Int?, historyId: Int?, type: HistoryDetailTypeContract?, contentType: HistoryContentTypeContract?, content: String?) {
        self.id = id
        self.historyId = historyId
        self.type = type
        self.contentType = contentType
        self.content = content
    }
}

public struct HistoryRecordContract: Codable, Equatable, Sendable {
    public let id: Int?
    public let name: String?
    public let detailList: [HistoryDetailContract]?

    public init(id: Int?, name: String?, detailList: [HistoryDetailContract]?) {
        self.id = id
        self.name = name
        self.detailList = detailList
    }
}
