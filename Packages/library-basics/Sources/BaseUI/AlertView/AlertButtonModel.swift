//
//  AlertAlertButtonModel.swift
//  LibraryCommon
//
//  Created by Janlor on 2024/7/3.
//

import UIKit

public struct AlertButtonModel {
    public let title: String
    public let type: AlertButtonType
    public let autoDismiss: Bool
    public let action: (() -> Void)?
    
    public init(title: String, type: AlertButtonType, autoDismiss: Bool = true, action: ( () -> Void)?) {
        self.title = title
        self.type = type
        self.autoDismiss = autoDismiss
        self.action = action
    }
}

public enum AlertButtonType {
    case confirm
    case cancel
    case destructive
    
    var backgroundColor: UIColor {
        switch self {
        case .confirm:
            return UIColor.clear
        case .cancel:
            return UIColor.clear
        case .destructive:
            return UIColor.systemRed
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .confirm:
            return UIColor.theme.accent
        case .cancel:
            return UIColor.theme.label
        case .destructive:
            return UIColor.white
        }
    }
    
    var borderColor: UIColor {
        switch self {
        case .confirm:
            return UIColor.clear
        case .cancel:
            return UIColor.clear
        case .destructive:
            return UIColor.clear
        }
    }
}
