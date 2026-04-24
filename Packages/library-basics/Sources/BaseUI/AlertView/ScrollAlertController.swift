//
//  ScrollAlertController.swift
//  LibraryCommon
//
//  Created by Janlor on 2024/7/3.
//

import UIKit

public class ScrollAlertController: UIViewController {
    // MARK: - UI Elements
    
    private let alertView = UIView()
    private var titleLabel: UILabel?
    private var contentTextView: UITextView?
    private var messageTextView: UITextView?
    private let buttonsStackView = UIStackView()
    
    // MARK: - Properties
    
    public var didDismissed: (() -> Void)? = nil
    public var buttonModels: [AlertButtonModel] = []
    public var didTapedLink: ((String) -> Void)?
    
    private var messageLinkDict: [String: String]?
    private var isToPush = false

    // MARK: - Initialization
    
    public init(title: String?, content: String?, buttonModels: [AlertButtonModel],
                message: String? = nil, messageDict: [String: String]? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.buttonModels = buttonModels
        setupUI(title: title, content: content, message: message, messageDict: messageDict)
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        appLog("ScrollAlertController 已经释放")
    }
    
    // MARK: - View Lifecycle
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isToPush { return }
        showAnimate()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isToPush = false
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentTextView?.isScrollEnabled = true
    }
    
    // MARK: - UI Setup
    
    private func setupUI(title: String?, content: String?, message: String?, messageDict: [String: String]?) {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        alertView.backgroundColor = UIColor.theme.background
        alertView.applyCapsule(.small)
        alertView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(alertView)
        
        var elements: [UIView] = []
        
        if let title = title {
            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.textColor = .theme.label
            titleLabel.font = UIFont.theme.title1
            titleLabel.textAlignment = .center
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            elements.append(titleLabel)
            self.titleLabel = titleLabel
        }
        
        if let content = content {
            let contentTextView = UITextView()
            contentTextView.text = content
            contentTextView.textColor = .theme.secondaryLabel
            contentTextView.font = UIFont.theme.subhead
            contentTextView.backgroundColor = .clear
            contentTextView.isEditable = false
            // 设置不可滚动即可 Self-Sizing
            contentTextView.isScrollEnabled = false
            // 设置 editable = NO 后 iOS 12 内容显示不全
            contentTextView.layoutManager.allowsNonContiguousLayout = false
            contentTextView.translatesAutoresizingMaskIntoConstraints = false
            elements.append(contentTextView)
            self.contentTextView = contentTextView
        }
        
        if let message = message, let linkDict = messageDict {
            messageLinkDict = linkDict
            
            let messageTextView = UITextView()
            messageTextView.text = content
            let attributedString = NSMutableAttributedString(string: message)
            for (key, value) in linkDict {
                guard let range = message.range(of: key) else { continue }
                let nsRange = NSRange(range, in: message)
                attributedString.addAttribute(.link, value: value, range: nsRange)
            }
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.theme.secondaryLabel,
                .font: UIFont.theme.subhead
            ]
            attributedString.addAttributes(attributes, range: NSRange(location: 0, length: message.count))
            messageTextView.attributedText = attributedString
            messageTextView.linkTextAttributes = [.foregroundColor: UIColor.theme.accent]
            messageTextView.delegate = self
            messageTextView.backgroundColor = .clear
            messageTextView.isEditable = false
            messageTextView.isScrollEnabled = false
            messageTextView.layoutManager.allowsNonContiguousLayout = false
            messageTextView.translatesAutoresizingMaskIntoConstraints = false
            elements.append(messageTextView)
            self.messageTextView = messageTextView
        }
        
        buttonsStackView.axis = buttonModels.count == 2 ? .horizontal : .vertical
        buttonsStackView.spacing = 10
        buttonsStackView.distribution = .fillEqually
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackView.heightAnchor.constraint(equalToConstant: 22+40).isActive = true
        
        for (index, model) in buttonModels.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(model.title, for: .normal)
            button.setTitleColor(model.type.textColor, for: .normal)
            button.titleLabel?.font = UIFont.theme.title2
            button.tag = index
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            buttonsStackView.addArrangedSubview(button)
        }
        elements.append(buttonsStackView)
        
        let stackView = UIStackView(arrangedSubviews: elements)
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        alertView.addSubview(stackView)
        
        let margin: CGFloat = 48
        NSLayoutConstraint.activate([
            alertView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            alertView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            alertView.leadingAnchor.constraint(greaterThanOrEqualTo: view.readableContentGuide.leadingAnchor, constant: margin-16),
            alertView.trailingAnchor.constraint(lessThanOrEqualTo: view.readableContentGuide.trailingAnchor, constant: -margin+16),
            alertView.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: margin),
            alertView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -margin),
            
            stackView.topAnchor.constraint(equalTo: alertView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: -24),
            stackView.bottomAnchor.constraint(equalTo: alertView.bottomAnchor, constant: -4)
        ])
        
        titleLabel?.setContentCompressionResistancePriority(.defaultHigh + 3, for: .vertical)
        contentTextView?.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        messageTextView?.setContentCompressionResistancePriority(.defaultHigh + 1, for: .vertical)
        buttonsStackView.setContentCompressionResistancePriority(.defaultHigh + 2, for: .vertical)
    }
    
    // MARK: - Actions
    
    public func dismissAlert(completion: (() -> Void)? = nil) {
        hiddenAnimate {
            self.dismiss(animated: false, completion:completion)
        }
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        let index = sender.tag
        guard self.buttonModels[index].autoDismiss else {
            self.buttonModels[index].action?()
            return
        }
        dismissAlert {
            self.buttonModels[index].action?()
        }
    }
}

extension ScrollAlertController: UITextViewDelegate {
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let urlString = URL.absoluteString
        if messageLinkDict?.values.contains(urlString) == true {
            didTapedLink?(urlString)
            return false
        }
        return true
    }
}

private extension ScrollAlertController {
    func showAnimate() {
        alertView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        alertView.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .beginFromCurrentState, animations: {
            self.alertView.transform = CGAffineTransform.identity
            self.alertView.alpha = 1
        }, completion: nil)
    }
    
    func hiddenAnimate(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .beginFromCurrentState, animations: {
            self.alertView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.alertView.alpha = 0
        }) { _ in
            completion?()
        }
    }
}
