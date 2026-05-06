//
//  SettingViewData.swift
//  LibraryCommon
//
//  Created by OpenAI on 2025/2/14.
//

import Foundation

struct SettingItemViewData {
    let title: String
    let detail: String?
    let iconSystemName: String?
    let action: SettingItemAction?
    let showsDisclosureIndicator: Bool
    let isDestructive: Bool
    let centeredTitle: Bool
    let isSelectable: Bool
}

struct SettingSectionViewData {
    let headerTitle: String?
    let footerTitle: String?
    let items: [SettingItemViewData]
}
