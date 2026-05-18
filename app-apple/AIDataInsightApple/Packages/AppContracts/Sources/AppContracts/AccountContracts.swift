public struct AccountSessionContract: Codable, Equatable, Sendable {
    public let accessToken: String?
    public let refreshToken: String?
    public let orgId: Int?
    public let username: String?
    public let isLogin: Bool

    public init(accessToken: String?, refreshToken: String?, orgId: Int?, username: String?, isLogin: Bool) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.orgId = orgId
        self.username = username
        self.isLogin = isLogin
    }
}

public struct AccountUserContract: Codable, Equatable, Sendable {
    public let id: Int?
    public let username: String?
    public let nickname: String?
    public let phone: String?

    public init(id: Int?, username: String?, nickname: String?, phone: String?) {
        self.id = id
        self.username = username
        self.nickname = nickname
        self.phone = phone
    }
}
