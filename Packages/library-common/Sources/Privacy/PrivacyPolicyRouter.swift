//
//  PrivacyPolicyRouter.swift
//  LibraryCommon
//
//  Created by Janlor on 2024/7/3.
//

import UIKit
import PrivacyProtocol
import BaseUI
import Router
import Environment

struct PrivacyPolicyRouter: RouterService {
    
    private static var hasShownPolicy = false

    init(){}
    
}

extension PrivacyPolicyRouter: RouterDestination {
    func to(_ arg: [AnyHashable: Any]?,
            _ closure: ((_ event: Any, _ arg: [AnyHashable: Any]?) -> Void)?) -> UIViewController {
        let vc = PrivacyPolicyViewController()
        vc.urlString = arg?["urlString"] as? String
        return vc
    }
}

extension PrivacyPolicyRouter: PrivacyProtocol {
    /// 是否同意所有协议
    func isAgreedAllPolicyAgreement() -> Bool {
        PolicyManager.isAgreedAllPolicyAgreement()
    }
    
    func showPolicyIfNeeded() {
        guard !PrivacyPolicyRouter.hasShownPolicy else { return }
        PrivacyPolicyRouter.hasShownPolicy = true
        guard !PolicyManager.isAgreedAllPolicyAgreement() else { return }
        showPolicyAgreementAlertController()
    }
    
    func showPolicyAgreementAlertController() {
        let title: String
        switch CommonTarget.target {
        default:
            title = NSLocalizedString("欢迎使用AI数据分析助手", bundle: .module, comment: "")
        }
        let content = NSLocalizedString("PrivacyPolicyContent", bundle: .module, comment: "")
        let buttons = [
            AlertButtonModel(title: NSLocalizedString("取消", bundle: .module, comment: ""), type: .cancel, autoDismiss: false, action: {
                UIApplication.shared.perform(#selector(URLSessionTask.suspend))
//                exit(0)
            }),
            AlertButtonModel(title: NSLocalizedString("同意并继续", bundle: .module, comment: ""), type: .confirm, action: {
                let version = PolicyManager.latestVersionDict()
                PolicyManager.saveAgreedVersionDict(version)
                NotificationCenter.default.post(name: .didAgreedAllPolicyAgreement, object: nil)
            }),
        ]
        let message = NSLocalizedString("PrivacyPolicyMessage", bundle: .module, comment: "")
        let linkDict = [
            NSLocalizedString("《隐私政策》", bundle: .module, comment: ""): PolicyManager.privacyPolicyURL
        ]
        let alert = ScrollAlertController(title: title, content: content, buttonModels: buttons, message: message, messageDict: linkDict)
        alert.didTapedLink = { link in
            guard let currentVC = UIWindow.app.currentViewController() else { return }
            let vc = PrivacyPolicyViewController()
            vc.urlString = link
            currentVC.navigationController?.pushViewController(vc, animated: true)
        }
        let nav = BaseNavigationController(rootViewController: alert)
        nav.view.backgroundColor = .clear
        nav.modalPresentationStyle = .overFullScreen
        nav.modalTransitionStyle = .crossDissolve
        guard let currentVC = UIWindow.app.currentViewController() else { return }
        currentVC.present(nav, animated: false)
    }
    
    /// 隐私协议链接
    func privacyPolicyURL() -> String {
        PolicyManager.privacyPolicyURL
    }
}
