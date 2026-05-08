//
//  SettingViewModel.swift
//  LibraryCommon
//
//  Created by Janlor on 5/1/26.
//

import Foundation
import AccountProtocol

@MainActor
final class SettingViewModel {
    private let repository: SettingRepository

    private(set) var sections: [SettingSectionViewData] = []

    var onReload: (() -> Void)?
    var onError: ((String) -> Void)?

    init(repository: SettingRepository = DefaultSettingRepository()) {
        self.repository = repository
    }

    func reloadData() {
        sections = makeSections(from: repository.loadSnapshot())
        onReload?()
    }

    func logout() async {
        do {
            try await repository.logout()
            NotificationCenter.default.post(name: .logoutSucceed, object: nil)
        } catch {
            onError?(error.localizedDescription)
        }
    }

    func numberOfSections() -> Int {
        sections.count
    }

    func numberOfRows(in section: Int) -> Int {
        guard sections.indices.contains(section) else { return 0 }
        return sections[section].items.count
    }

    func section(at index: Int) -> SettingSectionViewData? {
        guard sections.indices.contains(index) else { return nil }
        return sections[index]
    }

    func item(at indexPath: IndexPath) -> SettingItemViewData? {
        guard let section = section(at: indexPath.section),
              section.items.indices.contains(indexPath.row) else {
            return nil
        }
        return section.items[indexPath.row]
    }
}

private extension SettingViewModel {
    func makeSections(from snapshot: SettingSnapshot) -> [SettingSectionViewData] {
        let accountItems: [SettingItemViewData] = [
            SettingItemViewData(
                title: NSLocalizedString("昵称", bundle: .module, comment: ""),
                detail: displayText(snapshot.accountInfo.nickname),
                iconSystemName: "person.text.rectangle",
                action: nil,
                showsDisclosureIndicator: false,
                isDestructive: false,
                centeredTitle: false,
                isSelectable: false
            ),
            SettingItemViewData(
                title: NSLocalizedString("登录名", bundle: .module, comment: ""),
                detail: displayText(snapshot.accountInfo.username),
                iconSystemName: "at",
                action: nil,
                showsDisclosureIndicator: false,
                isDestructive: false,
                centeredTitle: false,
                isSelectable: false
            ),
            SettingItemViewData(
                title: NSLocalizedString("手机号", bundle: .module, comment: ""),
                detail: displayText(snapshot.accountInfo.phone),
                iconSystemName: "phone",
                action: nil,
                showsDisclosureIndicator: false,
                isDestructive: false,
                centeredTitle: false,
                isSelectable: false
            )
        ]

        var aboutItems: [SettingItemViewData] = []
        if snapshot.capability.canOpenPrivacy {
            aboutItems.append(
                SettingItemViewData(
                    title: NSLocalizedString("隐私政策", bundle: .module, comment: ""),
                    detail: nil,
                    iconSystemName: "hand.raised",
                    action: .privacy,
                    showsDisclosureIndicator: true,
                    isDestructive: false,
                    centeredTitle: false,
                    isSelectable: true
                )
            )
        }
        aboutItems.append(
            SettingItemViewData(
                title: NSLocalizedString("App版本", bundle: .module, comment: ""),
                detail: snapshot.appVersion,
                iconSystemName: "info.circle",
                action: nil,
                showsDisclosureIndicator: false,
                isDestructive: false,
                centeredTitle: false,
                isSelectable: false
            )
        )

        var sections: [SettingSectionViewData] = [
            SettingSectionViewData(
                headerTitle: NSLocalizedString("账户", bundle: .module, comment: ""),
                footerTitle: nil,
                items: accountItems
            ),
            SettingSectionViewData(
                headerTitle: NSLocalizedString("关于", bundle: .module, comment: ""),
                footerTitle: nil,
                items: aboutItems
            )
        ]

        if snapshot.capability.canLogout {
            sections.append(
                SettingSectionViewData(
                    headerTitle: nil,
                    footerTitle: nil,
                    items: [
                        SettingItemViewData(
                            title: NSLocalizedString("退出登录", bundle: .module, comment: ""),
                            detail: nil,
                            iconSystemName: nil,
                            action: .logout,
                            showsDisclosureIndicator: false,
                            isDestructive: true,
                            centeredTitle: true,
                            isSelectable: true
                        )
                    ]
                )
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
}
