//
//  File.swift
//  LibraryCommon
//
//  Created by Janlor on 4/22/26.
//

import Foundation
import UIKit

enum SettingToolType: CustomStringConvertible, CaseIterable, Hashable {
    case updatePassword
    case privacy
    case logout
    
    var description: String {
        switch self {
        case .updatePassword:
            return NSLocalizedString("修改密码", bundle: .module, comment: "")
        case .privacy:
            return NSLocalizedString("隐私政策", bundle: .module, comment: "")
        case .logout:
            return NSLocalizedString("退出登录", bundle: .module, comment: "")
        }
    }
    
    var image: UIImage? {
        switch self {
        case .updatePassword:
            return UIImage.imageNamed(for: "SettingMenu_lock")
        case .privacy:
            return UIImage.imageNamed(for: "SettingMenu_privacy")
        case .logout:
            return UIImage.imageNamed(for: "SettingMenu_export")
        }
    }
}
