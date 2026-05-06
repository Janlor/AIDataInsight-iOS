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

struct PrivacyPolicyRouter: RouterService {
    private static let sharedViewModel = PrivacyPolicyViewModel()
    private var viewModel: PrivacyPolicyViewModel { Self.sharedViewModel }

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
        viewModel.isAgreedAllPolicyAgreement()
    }
    
    func showPolicyIfNeeded() {
        guard viewModel.shouldShowPolicyAgreement() else { return }
        showPolicyAgreementAlertController()
    }
    
    func showPolicyAgreementAlertController() {
        let alertContent = viewModel.makeAlertContent()
        let buttons = [
            AlertButtonModel(title: alertContent.cancelTitle, type: .cancel, autoDismiss: false, action: {
                UIApplication.shared.perform(#selector(URLSessionTask.suspend))
//                exit(0)
            }),
            AlertButtonModel(title: alertContent.confirmTitle, type: .confirm, action: {
                viewModel.agreeToLatestPolicy()
            }),
        ]
        let alert = ScrollAlertController(
            title: alertContent.title,
            content: alertContent.content,
            buttonModels: buttons,
            message: alertContent.message,
            messageDict: alertContent.linkTexts
        )
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
        viewModel.privacyPolicyURL()
    }
}
