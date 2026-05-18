public struct ContractMetadata: Equatable, Sendable {
    public let version: String
    public let sourcePath: String

    public init(version: String = "0.1.0", sourcePath: String = "docs/cross-platform/contracts") {
        self.version = version
        self.sourcePath = sourcePath
    }
}
