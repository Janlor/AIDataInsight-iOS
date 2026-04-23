//
//  SettingToolView.swift
//  LibraryCommon
//
//  Created by Janlor on 4/22/26.
//

import UIKit
import PrivacyProtocol
import LoginProtocol
import AccountProtocol
import PrivacyProtocol
import BaseUI
import Router
import Environment
import SwifterSwift

class SettingToolView: UIView {
    /// 设置按钮
    private lazy var settingButton: UIButton = {
        let btn = UIButton(type: .system)
        let image = UIImage.imageNamed(for: "setting")
        btn.setImage(image, for: .normal)
        btn.tintColor = .theme.label
        btn.addTarget(self, action: #selector(didClickedSettingButton(_:)), for: .touchUpInside)
        if LiquidGlass.isEnabled {
            // do nothing
        } else {
            btn.contentEdgeInsets = UIEdgeInsets(top: 10, left: 8.0, bottom: 10, right: 8.0)
        }
        return btn
    }()
    
    private weak var viewController: UIViewController!
    private var dataSource: [SettingToolType] = SettingToolType.allCases
    
    func setupSetting(for vc: UIViewController) {
        viewController = vc
        setupDataSource()
        setupBarButtonItem()
    }
    
    private func setupDataSource() {
        var types = [SettingToolType]()
        if let _ = Router.perform(key: AccountProtocol.self) {
            types.append(.updatePassword)
        }
        if let _ = Router.perform(key: PrivacyProtocol.self) {
            types.append(.privacy)
        }
        if let _ = Router.perform(key: LoginProtocol.self) {
            types.append(.logout)
        }
        dataSource = types
    }
    
    private func setupBarButtonItem() {
        var settingItem: UIBarButtonItem!
        if #available(iOS 26.0, *), LiquidGlass.isEnabled {
            let children = dataSource.map { type in
                let image = type.image?.withRenderingMode(.alwaysTemplate)
                return UIAction(title: type.description, image: image, handler: { [weak self] _ in
                    self?.didSelectType(type)
                })
            }
            let menu = UIMenu(title: "", children: children)
            let image = UIImage.imageNamed(for: "setting")
            settingItem = UIBarButtonItem(image: image, menu: menu)
        } else {
            settingItem = UIBarButtonItem(customView: settingButton)
        }
        
        if let rightBarButtonItems = viewController.navigationItem.rightBarButtonItems, !rightBarButtonItems.isEmpty {
            var rightItems = rightBarButtonItems
            rightItems.insert(settingItem, at: 0)
            viewController.navigationItem.rightBarButtonItems = rightItems
        } else {
            viewController.navigationItem.rightBarButtonItem = settingItem
        }
    }
}

// MARK: - Action

private extension SettingToolView {
    /// 设置按钮点击事件
    @objc func didClickedSettingButton(_ sender: UIButton) {
        let popoverContent = PopoverViewController(config: nil)
        popoverContent.modalPresentationStyle = .popover
        
        popoverContent.didSelectIndex = { [weak self] index in
            guard let `self` = self else { return }
            guard index < self.dataSource.count else { return }
            let type = self.dataSource[index]
            self.didSelectType(type)
        }
        
        popoverContent.images = dataSource.compactMap { $0.image }
        popoverContent.options = dataSource.map { $0.description }
        
        var width: CGFloat = 0
        for option in popoverContent.options {
            let w = viewController.view.width - 2 * mSpacing
            let h = CGFloat.greatestFiniteMagnitude
            let size = option.textSize(font: .theme.subhead, maxSize: CGSize(width: w, height: h))
            width = max(width, size.width)
        }
        width += 70
        let count = CGFloat(popoverContent.options.count)
        popoverContent.preferredContentSize = CGSize(width: width, height: (count * 40.5 + 13))
        
        let popover = popoverContent.popoverPresentationController
        popover?.delegate = viewController as? any UIPopoverPresentationControllerDelegate
        popover?.sourceView = sender
        popover?.sourceRect = sender.bounds
        popover?.permittedArrowDirections = .up
        popover?.canOverlapSourceViewRect = false
        viewController.present(popoverContent, animated: true, completion: nil)
    }
    
    func didSelectType(_ type: SettingToolType) {
        switch type {
        case .updatePassword:
            Router.perform(key: AccountProtocol.self)?.toUpdatePassword(from: viewController)
        case .privacy:
            let urlString = Environment.server.privacyPolicyURL
            Router.push(from: viewController, to: PrivacyProtocol.self, animated: true)?
                .insert(params: ["urlString": urlString])
        case .logout:
            self.didClickedLogout()
        }
    }
    
    func didClickedLogout() {
        let title = NSLocalizedString("确认注销并退出系统吗？", bundle: .module, comment: "")
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.view.tintColor = .theme.label
        alert.addAction(UIAlertAction(title: NSLocalizedString("取消", bundle: .module, comment: ""), style: .cancel))
        alert.addAction(UIAlertAction(title: NSLocalizedString("确定", bundle: .module, comment: ""), style: .destructive, handler: { action in
            self.logoutAction()
        }))
        if let popover = alert.popoverPresentationController {
            popover.sourceView = self.settingButton
            popover.sourceRect = self.settingButton.bounds
        }
        viewController.present(alert, animated: true)
    }
    
    func logoutAction() {
        Router.perform(key: LoginProtocol.self)?.logout({ succeed, error in
            guard succeed == true, error == nil else {
                ProgressHUD.showError(withStatus: NSLocalizedString("退出登录失败", bundle: .module, comment: ""))
                return
            }
            NotificationCenter.default.post(name: .logoutSucceed, object: nil)
        })
    }
}
