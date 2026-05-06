//
//  DefaultSettingRepository.swift
//  LibraryCommon
//
//  Created by OpenAI on 2025/2/14.
//

import Foundation
import Router
import LoginProtocol
import PrivacyProtocol
import AccountProtocol

struct DefaultSettingRepository: SettingRepository {
    private let accountService: AccountUserStore?
    private let loginService: LoginProtocol?
    private let privacyService: PrivacyProtocol?

    init(
        accountService: AccountUserStore? = Router.perform(key: AccountUserStore.self) ?? Router.perform(key: AccountProtocol.self),
        loginService: LoginProtocol? = Router.perform(key: LoginProtocol.self),
        privacyService: PrivacyProtocol? = Router.perform(key: PrivacyProtocol.self)
    ) {
        self.accountService = accountService
        self.loginService = loginService
        self.privacyService = privacyService
    }

    func loadSnapshot() -> SettingSnapshot {
        let userInfo = accountService?.getUser(UserInfoMO.self)
        let shortVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "-"
        let buildVersion = (Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String) ?? "-"

        return SettingSnapshot(
            accountInfo: SettingAccountInfo(
                nickname: userInfo?.nikeName,
                username: userInfo?.username,
                phone: userInfo?.phone
            ),
            capability: SettingCapability(
                canUpdatePassword: accountService != nil,
                canOpenPrivacy: privacyService != nil,
                canLogout: loginService != nil
            ),
            appVersion: "\(shortVersion) (\(buildVersion))"
        )
    }

    func logout() async throws {
        guard let loginService else {
            throw NSError(
                domain: "DefaultSettingRepository.logout",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("退出登录失败", bundle: .module, comment: "")]
            )
        }

        try await loginService.logout()
    }
}
