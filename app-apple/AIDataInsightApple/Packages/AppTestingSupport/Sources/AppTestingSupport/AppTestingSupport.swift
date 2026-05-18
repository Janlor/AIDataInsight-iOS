import Foundation

public struct FixtureLoader: Sendable {
    public let rootURL: URL

    public init(rootURL: URL) {
        self.rootURL = rootURL
    }

    public func data(at relativePath: String) throws -> Data {
        try Data(contentsOf: rootURL.appending(path: relativePath))
    }
}
