//
//  SettingViewModel.swift
//  LibraryCommon
//
//  Created by Janlor on 5/1/26.
//

import Foundation
import UIKit
import Router
import AccountProtocol
import LoginProtocol
import PrivacyProtocol

final class SettingViewModel {
    private(set) var sections: [SettingSectionModel] = []

    func reloadData() {
        sections = makeSections()
    }

    func numberOfSections() -> Int {
        sections.count
    }

    func numberOfRows(in section: Int) -> Int {
        guard sections.indices.contains(section) else { return 0 }
        return sections[section].items.count
    }

    func section(at index: Int) -> SettingSectionModel? {
        guard sections.indices.contains(index) else { return nil }
        return sections[index]
    }

    func item(at indexPath: IndexPath) -> SettingItemModel? {
        guard let section = section(at: indexPath.section),
              section.items.indices.contains(indexPath.row) else {
            return nil
        }
        return section.items[indexPath.row]
    }
}

private extension SettingViewModel {
    func makeSections() -> [SettingSectionModel] {
        let userInfo = Router.perform(key: AccountProtocol.self)?.getUser(UserInfoMO.self)
        let hasAccountService = Router.perform(key: AccountProtocol.self) != nil
        let hasPrivacyService = Router.perform(key: PrivacyProtocol.self) != nil
        let hasLoginService = Router.perform(key: LoginProtocol.self) != nil

        var accountItems: [SettingItemModel] = [
            SettingItemModel(title: NSLocalizedString("昵称", bundle: .module, comment: ""),
                             detail: displayText(userInfo?.nikeName),
                             image: UIImage(systemName: "person.text.rectangle")),
            SettingItemModel(title: NSLocalizedString("登录名", bundle: .module, comment: ""),
                             detail: displayText(userInfo?.username),
                             image: UIImage(systemName: "at")),
            SettingItemModel(title: NSLocalizedString("手机号", bundle: .module, comment: ""),
                             detail: displayText(userInfo?.phone),
                             image: UIImage(systemName: "phone"))
        ]
//        if hasAccountService {
//            accountItems.append(
//                SettingItemModel(title: NSLocalizedString("修改密码", bundle: .module, comment: ""),
//                                 image: UIImage(systemName: "key.horizontal"),
//                                 accessory: .disclosureIndicator,
//                                 action: .updatePassword,
//                                 selectionStyle: .default)
//            )
//        }

        var aboutItems: [SettingItemModel] = []
        if hasPrivacyService {
            aboutItems.append(
                SettingItemModel(title: NSLocalizedString("隐私政策", bundle: .module, comment: ""),
                                 image: UIImage(systemName: "hand.raised"),
                                 accessory: .disclosureIndicator,
                                 action: .privacy,
                                 selectionStyle: .default)
            )
        }
        aboutItems.append(
            SettingItemModel(title: NSLocalizedString("App版本", bundle: .module, comment: ""),
                             detail: appVersionText(),
                             image: UIImage(systemName: "info.circle"))
        )

        var sections: [SettingSectionModel] = [
            SettingSectionModel(headerTitle: NSLocalizedString("账户", bundle: .module, comment: ""),
                                footerTitle: nil,
                                items: accountItems),
            SettingSectionModel(headerTitle: NSLocalizedString("关于", bundle: .module, comment: ""),
                                footerTitle: nil,
                                items: aboutItems)
        ]

        if hasLoginService {
            sections.append(
                SettingSectionModel(headerTitle: nil,
                                    footerTitle: nil,
                                    items: [
                                        SettingItemModel(title: NSLocalizedString("退出登录", bundle: .module, comment: ""),
//                                                         image: UIImage(systemName: "rectangle.portrait.and.arrow.right"),
                                                         action: .logout,
                                                         isDestructive: true,
                                                         centeredTitle: true,
                                                         selectionStyle: .default)
                                    ])
            )
        }

        return sections
    }

    func displayText(_ text: String?) -> String {
        guard let text, !text.isEmpty else {
            return NSLocalizedString("未设置", bundle: .module, comment: "")
        }
        return text
    }

    func appVersionText() -> String {
        let shortVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "-"
        let buildVersion = (Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String) ?? "-"
        return "\(shortVersion) (\(buildVersion))"
    }
}
