import Foundation

public enum FixtureLoaderError: Error, Equatable, Sendable {
    case missingFixture(String)
}

public struct FixtureLoader: Sendable {
    public let rootURL: URL

    public init(rootURL: URL) {
        self.rootURL = rootURL
    }

    public func data(at relativePath: String) throws -> Data {
        let url = rootURL.appending(path: relativePath)
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw FixtureLoaderError.missingFixture(relativePath)
        }
        return try Data(contentsOf: url)
    }

    public func decode<Value: Decodable>(_ type: Value.Type, at relativePath: String, decoder: JSONDecoder = JSONDecoder()) throws -> Value {
        try decoder.decode(type, from: data(at: relativePath))
    }
}

public enum ContractFixturePath {
    public static let loginSnakeCaseResponse = "api/login-response-snake-case.json"
    public static let response401 = "api/response-401.json"
    public static let response402 = "api/response-402.json"
    public static let aiChatInitial = "ui/ai-chat-initial.json"
    public static let historyInitial = "ui/history-initial.json"
}
