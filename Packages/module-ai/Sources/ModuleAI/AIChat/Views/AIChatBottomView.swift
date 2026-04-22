//
//  AIChatBottomView.swift
//  ModuleAI
//
//  Created by Janlor on 2024/10/23.
//

import UIKit
import BaseUI

protocol AIChatBottomViewDelegate: AnyObject {
    func chatBottomView(_ chatBottomView: AIChatBottomView, didClickedClear sender: UIButton)
    func chatBottomView(_ chatBottomView: AIChatBottomView, didTapSendWithText text: String)
}

class AIChatBottomView: UIView {
    weak var delegate: AIChatBottomViewDelegate?
    
    var isEnabled = true {
        didSet {
            sendButton.isEnabled = isEnabled
            sendButton.alpha = isEnabled ? 1 : 0.2
        }
    }
    
    var isClearEnabled = false {
        didSet {
            clearButton.isEnabled = isClearEnabled
        }
    }
    
    private let clearButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.tintColor = .theme.label
        btn.applyCapsule(.custom(21))
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.aiSeparator.cgColor
        btn.setImage(UIImage.imageNamed(for: "clear"), for: .normal)
        btn.backgroundColor = UIColor.theme.secondaryGroupedBackground
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .theme.secondaryGroupedBackground
        view.applyCapsule(.custom(21))
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.aiSeparator.cgColor
        view.backgroundColor = UIColor.theme.secondaryGroupedBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let inputTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
        textView.isScrollEnabled = false
        textView.returnKeyType = .send
        textView.backgroundColor = .clear
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("请输入您的数据分析查询。", bundle: .module, comment: "")
        label.textColor = .theme.quaternaryLabel
        label.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var textViewHeightConstraint: NSLayoutConstraint?
    private let maxTextViewHeight: CGFloat = 120 // 最大高度，大约5行文字
    private let defaultViewHeight: CGFloat = 33
    
    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage.imageNamed(for: "send"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard let previousTraitCollection = previousTraitCollection else { return }
        if (previousTraitCollection.hasDifferentColorAppearance(comparedTo: traitCollection)) {
            clearButton.layer.borderColor = UIColor.aiSeparator.cgColor
            containerView.layer.borderColor = UIColor.aiSeparator.cgColor
        }
    }
    
    private func setupViews() {
        addSubview(clearButton)
        addSubview(containerView)
        containerView.addSubview(inputTextView)
        containerView.addSubview(placeholderLabel)
        containerView.addSubview(sendButton)
        
        textViewHeightConstraint = inputTextView.heightAnchor.constraint(equalToConstant: defaultViewHeight)
        
        NSLayoutConstraint.activate([
            clearButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: mSpacing),
            clearButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            clearButton.widthAnchor.constraint(equalToConstant: 42),
            clearButton.heightAnchor.constraint(equalToConstant: 42),
            
            containerView.leadingAnchor.constraint(equalTo: clearButton.trailingAnchor, constant: 4),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -mSpacing),
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            inputTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 11),
            inputTextView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4.5),
            inputTextView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -4.5),
            textViewHeightConstraint!,
            
            placeholderLabel.leadingAnchor.constraint(equalTo: inputTextView.leadingAnchor, constant: 5),
            placeholderLabel.topAnchor.constraint(equalTo: inputTextView.topAnchor, constant: 8),
            placeholderLabel.trailingAnchor.constraint(lessThanOrEqualTo: inputTextView.trailingAnchor, constant: -5),
            
            sendButton.leadingAnchor.constraint(equalTo: inputTextView.trailingAnchor),
            sendButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            sendButton.bottomAnchor.constraint(equalTo: inputTextView.bottomAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: (22 + 2 * 16)),
            sendButton.heightAnchor.constraint(equalToConstant: defaultViewHeight)
        ])
        
        clearButton.addTarget(self, action: #selector(didClickedClearButton(_:)), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(didClickedSendButton(_:)), for: .touchUpInside)
        inputTextView.delegate = self
    }
    
    private func setupData() {
        isClearEnabled = false
        isEnabled = true
        inputTextView.text = nil
        placeholderLabel.isHidden = false
    }
    
    @objc private func didClickedClearButton(_ sender: UIButton) {
        delegate?.chatBottomView(self, didClickedClear: sender)
        setupData()
    }
    
    @objc private func didClickedSendButton(_ sender: UIButton) {
        guard let text = inputTextView.text, !text.trimmed.isEmpty else { return }
        delegate?.chatBottomView(self, didTapSendWithText: text)
        inputTextView.text = ""
        textViewDidChange(inputTextView)
    }
    
    override var canBecomeFirstResponder: Bool {
        return inputTextView.canBecomeFirstResponder
    }
    
    override func becomeFirstResponder() -> Bool {
        return inputTextView.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        return inputTextView.resignFirstResponder()
    }
}

extension AIChatBottomView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !inputTextView.text.isEmpty
        
        let size = CGSize(width: inputTextView.frame.width, height: .infinity)
        let estimatedSize = inputTextView.sizeThatFits(size)
        
        var toHeight: CGFloat = 0
        if estimatedSize.height <= maxTextViewHeight {
            toHeight = estimatedSize.height
            inputTextView.isScrollEnabled = false
        } else {
            toHeight = maxTextViewHeight
            inputTextView.isScrollEnabled = true
        }
        
        guard textViewHeightConstraint?.constant != toHeight else { return }
        textViewHeightConstraint?.constant = toHeight
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            if isEnabled {
                sendButton.sendActions(for: .touchUpInside)
            }
            return false
        }
        return true
    }
}
