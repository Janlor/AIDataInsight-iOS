//
//  ActionSheetController.swift
//  LibraryCommon
//
//  Created by Janlor on 4/22/26.
//

import UIKit
import BaseKit

open class ActionSheetController: UIViewController {
    
    private var actions: [SheetAction] = []
    private var titleText: String?
    private var messageText: String?
    
    private lazy var dimmingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.alpha = 0
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissAction)))
        return view
    }()
    
    private lazy var sheetView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.theme.background
        view.applyTopRadius(.large)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var actionStackView: PanSelectionStackView = {
        let stack = PanSelectionStackView()
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var cancelButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(NSLocalizedString("取消", bundle: .module, comment: ""), for: .normal)
        btn.titleLabel?.themeFont = .theme.body
        btn.backgroundColor = .theme.secondaryBackground
        btn.setTitleColor(.theme.secondaryLabel, for: .normal)
        btn.applyCapsule(.medium)
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.theme.quinaryLabel.cgColor
        let space = Spacing.small
        btn.contentEdgeInsets = UIEdgeInsets(top: space, left: 0, bottom: space, right: 0)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
        return btn
    }()
    
    // MARK: - Public
    
    public func addAction(_ action: SheetAction) {
        actions.append(action)
    }
    
    // MARK: - Life Cycle
    
    public init(title: String? = nil, message: String? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.titleText = title
        self.messageText = message
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        showAnimate()
    }
    
    // MARK: - UI
    
    private func setupUI() {
        view.addSubview(dimmingView)
        view.addSubview(sheetView)
        sheetView.addSubview(cancelButton)
        sheetView.addSubview(actionStackView)
        
        NSLayoutConstraint.activate([
            dimmingView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            sheetView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            sheetView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor, constant: -16),
            sheetView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor, constant: 16),
            
            cancelButton.bottomAnchor.constraint(equalTo: sheetView.safeAreaLayoutGuide.bottomAnchor, constant: -Spacing.small),
            cancelButton.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: Spacing.medium),
            cancelButton.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor, constant: -Spacing.medium),
            
            actionStackView.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: Spacing.medium),
            actionStackView.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor, constant: -Spacing.medium),
            actionStackView.topAnchor.constraint(equalTo: sheetView.topAnchor),
            actionStackView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -Spacing.small)
        ])
        
        actions.forEach { action in
            let btn = createActionButton(action)
            btn.tag = actions.firstIndex(of: action) ?? 0
            actionStackView.addArrangedSubview(btn)
            let separator = createSeparatorView()
            actionStackView.addArrangedSubview(separator)
        }
    }
    
    private func createActionButton(_ action: SheetAction) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setAttributedTitle(action.title, for: .normal)
        let space = Spacing.medium
        btn.contentEdgeInsets = UIEdgeInsets(top: space, left: 0, bottom: space, right: 0)
        btn.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        return btn
    }
    
    private func createSeparatorView() -> UIView {
        let view = UIView()
        view.backgroundColor = .theme.separator
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return view
    }
    
    // MARK: - Actions
    
    // Action button tapped
    @objc private func buttonTapped(_ sender: UIButton) {
        let action = actions[sender.tag]
        action.handler?(action)
        dismissAction()
    }
    
    // Dismiss the action sheet with animation
    @objc private func dismissAction() {
        hiddenAnimate {
            self.dismiss(animated: false, completion: nil)
        }
    }
}

private extension ActionSheetController {
    func showAnimate() {
        self.dimmingView.alpha = 0
        self.sheetView.transform = CGAffineTransform(translationX: 0, y: self.sheetView.bounds.height)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .beginFromCurrentState, animations: {
            self.sheetView.transform = CGAffineTransform.identity
            self.dimmingView.alpha = 1
        }, completion: nil)
    }
    
    func hiddenAnimate(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .beginFromCurrentState, animations: {
            self.dimmingView.alpha = 0
            self.sheetView.transform = CGAffineTransform(translationX: 0, y: self.sheetView.bounds.height)
        }) { _ in
            completion?()
        }
    }
}

public class SheetAction: Equatable {
    let title: NSAttributedString
    var handler: ((SheetAction) -> Void)?
    
    public init(title: NSAttributedString, handler: ((SheetAction) -> Void)? = nil) {
        self.title = title
        self.handler = handler
    }
    
    public static func == (lhs: SheetAction, rhs: SheetAction) -> Bool {
        lhs.title == rhs.title
    }
}
