public struct SettingAccountInfoContract: Codable, Equatable, Sendable {
    public let nickname: String?
    public let username: String?
    public let phone: String?

    public init(nickname: String?, username: String?, phone: String?) {
        self.nickname = nickname
        self.username = username
        self.phone = phone
    }
}

public struct SettingCapabilityContract: Codable, Equatable, Sendable {
    public let canUpdatePassword: Bool
    public let canOpenPrivacy: Bool
    public let canLogout: Bool

    public init(canUpdatePassword: Bool, canOpenPrivacy: Bool, canLogout: Bool) {
        self.canUpdatePassword = canUpdatePassword
        self.canOpenPrivacy = canOpenPrivacy
        self.canLogout = canLogout
    }
}

public struct SettingSnapshotContract: Codable, Equatable, Sendable {
    public let accountInfo: SettingAccountInfoContract
    public let capability: SettingCapabilityContract
    public let appVersion: String

    public init(accountInfo: SettingAccountInfoContract, capability: SettingCapabilityContract, appVersion: String) {
        self.accountInfo = accountInfo
        self.capability = capability
        self.appVersion = appVersion
    }
}
