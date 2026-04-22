//
//  PrivacyProtocol.swift
//  Protocol
//
//  Created by Janlor on 2024/7/3.
//

import UIKit

public extension Notification.Name {
    /// 同意所有协议的通知
    static let didAgreedAllPolicyAgreement = Notification.Name("PrivacyPolicy.didAgreedAllPolicyAgreement")
}

public protocol PrivacyProtocol {
    /// 是否同意所有协议
    func isAgreedAllPolicyAgreement() -> Bool
    /// 打开隐私政策弹窗 会自动判断是否同意
    func showPolicyIfNeeded()
    /// 直接打开隐私政策弹窗
    func showPolicyAgreementAlertController()
}
