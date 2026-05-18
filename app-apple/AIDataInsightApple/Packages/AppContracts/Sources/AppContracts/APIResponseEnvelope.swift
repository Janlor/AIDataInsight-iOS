public struct APIResponseEnvelope<Payload: Decodable & Sendable>: Decodable, Sendable {
    public let code: Int
    public let msg: String
    public let data: Payload?
    public let trace: String?
    public let tid: String?
}
