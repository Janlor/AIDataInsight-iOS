//
//  SettingModels.swift
//  LibraryCommon
//
//  Created by Janlor on 5/1/26.
//

import UIKit

enum SettingItemAccessory {
    case none
    case disclosureIndicator
}

enum SettingItemAction {
    case updatePassword
    case privacy
    case logout
}

struct SettingItemModel {
    let title: String
    let detail: String?
    let image: UIImage?
    let accessory: SettingItemAccessory
    let action: SettingItemAction?
    let isDestructive: Bool
    let centeredTitle: Bool
    let selectionStyle: UITableViewCell.SelectionStyle

    init(title: String,
         detail: String? = nil,
         image: UIImage? = nil,
         accessory: SettingItemAccessory = .none,
         action: SettingItemAction? = nil,
         isDestructive: Bool = false,
         centeredTitle: Bool = false,
         selectionStyle: UITableViewCell.SelectionStyle = .none) {
        self.title = title
        self.detail = detail
        self.image = image
        self.accessory = accessory
        self.action = action
        self.isDestructive = isDestructive
        self.centeredTitle = centeredTitle
        self.selectionStyle = selectionStyle
    }
}

struct SettingSectionModel {
    let headerTitle: String?
    let footerTitle: String?
    let items: [SettingItemModel]
}
