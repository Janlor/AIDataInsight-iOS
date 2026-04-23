//
//  AIChatIntentCell.swift
//  ModuleAI
//
//  Created by Janlor on 4/22/26.
//

import UIKit
import BaseUI

protocol AIChatIntentCellDelegate: AnyObject {
    func chatIntentCell(_ cell: AIChatIntentCell, didTapText text: String, chatModel: AIChat?)
}

class AIChatIntentCell: AIChatCell {
    weak var delegate: AIChatIntentCellDelegate?

    public var chatModel: AIChat? {
        didSet {
            updateChatModel(chatModel)
        }
    }

    private var models: [String]?
    
    private var selectedText: String? {
        didSet {
            continueButton.isEnabled = selectedText != nil && !selectedText!.isEmpty
        }
    }
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .fill
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var optionsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .fill
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var textContainerView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.aiSeparator.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var textField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var continueButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.titleLabel?.font = .theme.subhead
        btn.setTitleColor(UIColor.aiAccent, for: .normal)
        btn.setTitleColor(UIColor.aiAccent.withAlphaComponent(0.2), for: .disabled)
        btn.setTitle(NSLocalizedString("继续", bundle: .module, comment: ""), for: .normal)
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(didClickedContinueButton(_:)), for: .touchUpInside)
        return btn
    }()
    
    private var viewManager: DynamicViewManager<String, UIButton>!
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard let previousTraitCollection = previousTraitCollection else { return }
        if (previousTraitCollection.hasDifferentColorAppearance(comparedTo: traitCollection)) {
            textContainerView.layer.borderColor = UIColor.aiSeparator.cgColor
        }
    }
    
    override func setupViews() {
        super.setupViews()
        messageLabelBottom.isActive = false
        
        bubbleView.addSubview(stackView)
        stackView.addArrangedSubview(optionsStackView)
        stackView.addArrangedSubview(textContainerView)
        textContainerView.addSubview(textField)
        textContainerView.addSubview(continueButton)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: verSpacing),
            stackView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: contentEdge.left),
            stackView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -contentEdge.right),

            textContainerView.heightAnchor.constraint(equalToConstant: 40),
            
            textField.topAnchor.constraint(equalTo: textContainerView.topAnchor),
            textField.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor, constant: 12),
            textField.trailingAnchor.constraint(equalTo: continueButton.leadingAnchor),
            textField.bottomAnchor.constraint(equalTo: textContainerView.bottomAnchor),

            continueButton.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor),
            continueButton.centerYAnchor.constraint(equalTo: textContainerView.centerYAnchor)
        ])
        
        let bottomLayout = stackView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -16)
        bottomLayout.priority = .required - 1 // 消除警告
        bottomLayout.isActive = true
        
        viewManager = DynamicViewManager(container: optionsStackView,
                                         createView: createChildView,
                                         setupView: setupChildView(_:_:),
                                         extraSetup: extraSetupView(_:_:))
        
        continueButton.isEnabled = false
    }
    
    override func addNotifications() {
        super.addNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChanged(_:)), name: UITextField.textDidChangeNotification, object: textField)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        textField.text = nil
        selectedText = nil
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension AIChatIntentCell {
    func updateChatModel(_ chatModel: AIChat?) {
        var richText: [AIChatRichText] = [
            AIChatRichText(text: "为了更准确地理解您的意图，我需要以下信息： \n"),
        ]

        switch chatModel?.intentType {
        case .time:
            richText.append(AIChatRichText(text: "请提供具体的"))
            richText.append(AIChatRichText(text: "时间范围").bold)
            richText.append(AIChatRichText(text: "，例如："))
            richText.append(AIChatRichText(text: "去年、今年第一季度、本月、2024年6-9月。").bold)

            models = ["今年", "今年第一季度", "本月", "上月"]
            viewManager.setupModels(models)

            textContainerView.isHidden = false
            textField.attributedPlaceholder = NSAttributedString(string: "请输入时间范围…", attributes: [
                .font: UIFont.theme.subhead,
                .foregroundColor: UIColor.theme.quaternaryLabel
            ])
        case .index:
            richText.append(AIChatRichText(text: "查询发现"))
            richText.append(AIChatRichText(text: "“业绩”").bold)
            richText.append(AIChatRichText(text: "对应多个指标名称，请选择一个。"))

            models = ["销售额", "采购额"]
            viewManager.setupModels(models)

            textContainerView.isHidden = true
        default:
            break
        }
        
        let attributedString = AIChatRichText.attributedString(from: richText)
        messageLabel.attributedText = attributedString
    }
}

extension AIChatIntentCell {
    @objc func textDidChanged(_ noti: Notification) {
        guard let view = noti.object as? UITextField else { return }
        guard view == textField else { return }
        selectedText = view.text
    }
}

extension AIChatIntentCell {
    @objc func didClickedContinueButton(_ sender: UIButton) {
        guard let text = selectedText else { return }
        delegate?.chatIntentCell(self, didTapText: text, chatModel: chatModel)
    }
}

extension AIChatIntentCell {
    private func createChildView() -> UIButton {
        let view = UIButton(type: .custom)
        view.setTitleColor(.theme.label, for: .normal)
        view.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        view.backgroundColor = .theme.tertieryGroupedBackground
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapedChildView(_:))))
        view.heightAnchor.constraint(equalToConstant: 40).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private func setupChildView(_ view: UIButton, _ model: String) {
        view.setTitle(model, for: .normal)
    }
    
    private func extraSetupView(_ view: UIButton, _ index: Int) {
        view.tag = index
    }
    
    @objc func didTapedChildView(_ tap: UITapGestureRecognizer) {
        guard let view = tap.view as? UIButton else { return }
        guard let models = models else { return }
        guard view.tag < models.count else { return }
        view.isSelected.toggle()
        textField.text = nil
        let model = models[view.tag]
        selectedText = model
        delegate?.chatIntentCell(self, didTapText: model, chatModel: chatModel)
    }
}
