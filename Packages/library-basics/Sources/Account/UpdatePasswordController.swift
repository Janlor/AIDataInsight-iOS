//
//  UpdatePasswordController.swift
//  LibraryCommon
//
//  Created by Janlor on 4/22/26.
//

import UIKit
import AccountProtocol
import BaseUI
import Router
import Networking
import AppSecurity

class UpdatePasswordController: BaseViewController {
    /// 最大密码长度
    private let kMaxPasswordCount = 20
    
    /// 交互震动反馈
    private lazy var feedbackGenerator: UINotificationFeedbackGenerator = {
        let gen = UINotificationFeedbackGenerator()
        gen.prepare()
        return gen
    }()
    
    /// scrollView
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView.init()
        scroll.isScrollEnabled = true
        scroll.alwaysBounceVertical = true
        scroll.keyboardDismissMode = .onDrag
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .theme.secondaryGroupedBackground
        view.applyCapsule(.medium)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .theme.label
        label.themeFont = .theme.title2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var accountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .theme.tertieryLabel
        label.themeFont = .theme.caption1
        label.text = NSLocalizedString("账号：", bundle: .module, comment: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// 账号框
    private lazy var usernameTextField: UITextField = {
        let text = createTextField("")
//        text.textContentType = .username
        text.textColor = .theme.tertieryLabel
        text.themeFont = .theme.caption1
        text.isUserInteractionEnabled = false
        return text
    }()
    
    private lazy var passwordLabel: UILabel = {
        return createTitleLabel(NSLocalizedString("旧密码", bundle: .module, comment: ""))
    }()
    
    private lazy var passwordTextField: UITextField = {
        let text = createTextField(NSLocalizedString("请输入", bundle: .module, comment: ""))
        // 先开启 secure，再设置 contentType
        text.isSecureTextEntry = true
        // 明确标为“现有密码”
        text.textContentType = .password
        // 不要在旧密码上设置 passwordRules
        return text
    }()
    
    private lazy var separatorView1: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.theme.separator
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var newPasswordLabel1: UILabel = {
        return createTitleLabel(NSLocalizedString("新密码", bundle: .module, comment: ""))
    }()
    
    private lazy var newPasswordTextField1: UITextField = {
        let text = createTextField(NSLocalizedString("请输入", bundle: .module, comment: ""))
        text.isSecureTextEntry = true
        text.keyboardType = .asciiCapable
        // 在设置 isSecureTextEntry 后再设置 contentType / rules
        text.textContentType = .newPassword
        text.passwordRules = passwordRules()   // 仅在主新密码字段设置 rules
        return text
    }()
    
    private lazy var separatorView2: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.theme.separator
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var newPasswordLabel2: UILabel = {
        return createTitleLabel(NSLocalizedString("确认新密码", bundle: .module, comment: ""))
    }()
    
    private lazy var newPasswordTextField2: UITextField = {
        let text = createTextField(NSLocalizedString("请输入", bundle: .module, comment: ""))
        text.isSecureTextEntry = true
        text.keyboardType = .asciiCapable
        text.textContentType = .newPassword
        // 很重要：不要在确认字段也设置 passwordRules（system 可能会把生成密码同时填充到所有有 rules 的 secure field）
        text.passwordRules = nil
        return text
    }()
    
    private lazy var separatorView3: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.theme.separator
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var descLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("PasswordRuleDescription", bundle: .module, comment: "")
        label.textColor = .theme.tertieryLabel
        label.themeFont = .theme.caption1
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 在 passwordTextField 和 newPasswordTextField1 之间插入这个占位 username field：
    private lazy var middleUsernameField: UITextField = {
        let t = UITextField()
        t.translatesAutoresizingMaskIntoConstraints = false
        t.textColor = .clear     // 用户看不到文字，但 field 仍“可见”
        t.backgroundColor = .clear
        t.isUserInteractionEnabled = false
        t.borderStyle = .none
        // VERY IMPORTANT: set contentType so system recognizes it as username
        t.textContentType = .username
        // 不要把它 hidden 或 alpha = 0 ——系统会忽略隐藏的 field
        // 通过设置高度很小来最小化视觉影响：
        return t
    }()
    
    private lazy var buttonView: NormalBottomView = {
        let view = NormalBottomView()
        view.title = NSLocalizedString("确认修改", bundle: .module, comment: "")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.didClicked = { [weak self] sender in
            self?.didClickedCommitButton(sender)
        }
        view.isEnabled = false // 默认不可用
        return view
    }()
    private var buttonViewWidth: NSLayoutConstraint?
    
    // 标记密码是否成功保存到服务器，避免自动生成的强密码未提交到服务器，但是已经保存到 password app 中了。
    private var didSubmitPasswordChange = false
    
    // MARK: - Life Cycle
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        buttonViewWidth?.constant = view.readableContentGuide.layoutFrame.width - 2 * 8.0
        view.accessibilityElements = [passwordTextField, middleUsernameField, newPasswordTextField1, newPasswordTextField2]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 如果页面要离开但未提交修改，清空新密码输入框，避免 iOS 误以为变更已完成并保存到 Keychain
        if !didSubmitPasswordChange {
            // 清掉新密码字段（不要 hidden 或 alpha = 0，否则系统仍可能忽略）
            newPasswordTextField1.text = ""
            newPasswordTextField2.text = ""
            // 如果你希望也阻止键盘上的 suggestion，取消 first responder
            newPasswordTextField1.resignFirstResponder()
            newPasswordTextField2.resignFirstResponder()
        }
    }

    override func setupUI() {
        super.setupUI()
        setupBackground()
        addSubviews()
    }
    
    override func setupData() {
        super.setupData()
        
        navigationItem.title = NSLocalizedString("修改密码", bundle: .module, comment: "")
        
        let user = Router.perform(key: AccountProtocol.self)?.getUser(UserInfoMO.self)
        let nikeName = user?.nikeName
        let username = user?.username
        nameLabel.text = "Hello，\(nikeName ?? "")"
        usernameTextField.text = username
        middleUsernameField.text = username
    }
}

private extension UpdatePasswordController {
    /// 添加子视图
    func addSubviews() {
        view.addSubview(scrollView)
        
        if LiquidGlass.isEnabled {
            buttonViewWidth = buttonView.widthAnchor.constraint(equalToConstant: view.readableContentGuide.layoutFrame.width - 2 * 8.0)
            buttonViewWidth?.isActive = true
            let item = UIBarButtonItem(customView: buttonView)
            toolbarItems = [item]
            navigationController?.setToolbarHidden(false, animated: true)
            buttonView.backgroundColor = .clear
        } else {
            view.addSubview(buttonView)
            buttonView.backgroundColor = .theme.secondaryGroupedBackground
            NSLayoutConstraint.activate([
                buttonView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                buttonView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                buttonView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
        }
        
        scrollView.addSubview(contentView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(accountLabel)
        contentView.addSubview(usernameTextField)
        
        contentView.addSubview(separatorView1)
        contentView.addSubview(separatorView2)
        contentView.addSubview(separatorView3)
        
        contentView.addSubview(passwordLabel)
        contentView.addSubview(passwordTextField)
        
        contentView.addSubview(middleUsernameField)
        
        contentView.addSubview(newPasswordLabel1)
        contentView.addSubview(newPasswordTextField1)
        
        contentView.addSubview(newPasswordLabel2)
        contentView.addSubview(newPasswordTextField2)
        
        contentView.addSubview(descLabel)
        
        // 然后在布局 constraint 时，把 middleUsernameField 放在旧密码和新密码之间，给它一个 very small height（例如 1pt）
        
        let fieldHeight: CGFloat = 50
        var fieldLeft: CGFloat = 0
        let titles = [
            NSLocalizedString("旧密码", bundle: .module, comment: ""),
            NSLocalizedString("新密码", bundle: .module, comment: ""),
            NSLocalizedString("确认新密码", bundle: .module, comment: "")
        ]
        for text in titles {
            let w = view.bounds.size.width - 2 * view.mSpacing
            let h = CGFloat.greatestFiniteMagnitude
            let size = text.textSize(font: .theme.title3, maxSize: CGSize(width: w, height: h))
            fieldLeft = max(fieldLeft, size.width)
        }
        fieldLeft += 28
        
        if #available(iOS 15.0, *) {
            scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        } else {
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        }
        
        let padding: CGFloat = 16
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.leadingAnchor.constraint(equalTo: scrollView.readableContentGuide.leadingAnchor, constant: padding-8.0),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 12),
            contentView.trailingAnchor.constraint(equalTo: scrollView.readableContentGuide.trailingAnchor, constant: -padding + 8.0),
            contentView.heightAnchor.constraint(equalToConstant: 445),
            
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -padding),
            
            accountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            accountLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6),
            accountLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -padding),
            
            usernameTextField.leadingAnchor.constraint(equalTo: accountLabel.trailingAnchor, constant: 4),
            usernameTextField.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -padding),
            usernameTextField.centerYAnchor.constraint(equalTo: accountLabel.centerYAnchor),
            
            separatorView1.topAnchor.constraint(equalTo: accountLabel.bottomAnchor, constant: padding + fieldHeight),
            separatorView1.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            separatorView1.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            separatorView1.heightAnchor.constraint(equalToConstant: 1),
            
            separatorView2.topAnchor.constraint(equalTo: separatorView1.bottomAnchor, constant: fieldHeight),
            separatorView2.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            separatorView2.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            separatorView2.heightAnchor.constraint(equalToConstant: 1),
            
            separatorView3.topAnchor.constraint(equalTo: separatorView2.bottomAnchor, constant: fieldHeight),
            separatorView3.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            separatorView3.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            separatorView3.heightAnchor.constraint(equalToConstant: 1),
            
            passwordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: fieldLeft),
            passwordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            passwordTextField.bottomAnchor.constraint(equalTo: separatorView1.topAnchor),
            passwordTextField.heightAnchor.constraint(equalToConstant: fieldHeight),
            
            passwordLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            passwordLabel.centerYAnchor.constraint(equalTo: passwordTextField.centerYAnchor),
            
            middleUsernameField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: fieldLeft),
            middleUsernameField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            middleUsernameField.bottomAnchor.constraint(equalTo: newPasswordTextField1.topAnchor, constant: -8),
            middleUsernameField.heightAnchor.constraint(equalToConstant: 1), // 极小高度但非隐藏
            
            newPasswordTextField1.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: fieldLeft),
            newPasswordTextField1.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            newPasswordTextField1.bottomAnchor.constraint(equalTo: separatorView2.topAnchor),
            newPasswordTextField1.heightAnchor.constraint(equalToConstant: fieldHeight),
            
            newPasswordLabel1.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            newPasswordLabel1.centerYAnchor.constraint(equalTo: newPasswordTextField1.centerYAnchor),
            
            newPasswordTextField2.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: fieldLeft),
            newPasswordTextField2.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            newPasswordTextField2.bottomAnchor.constraint(equalTo: separatorView3.topAnchor),
            newPasswordTextField2.heightAnchor.constraint(equalToConstant: fieldHeight),
            
            newPasswordLabel2.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            newPasswordLabel2.centerYAnchor.constraint(equalTo: newPasswordTextField2.centerYAnchor),
            
            descLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            descLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            descLabel.topAnchor.constraint(equalTo: separatorView3.bottomAnchor, constant: 12),
        ])
    }
    
    func createTextField(_ placeholder: String) -> UITextField {
        let text = UITextField()
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.theme.subhead,
            .foregroundColor: UIColor.theme.quaternaryLabel
        ]
        text.attributedPlaceholder = NSAttributedString.init(string: placeholder, attributes: attributes)
        text.textColor = UIColor.theme.label
        text.themeFont = .theme.subhead
        text.clearButtonMode = .whileEditing
        text.returnKeyType = .done
        // 禁用拼写检查和自动纠正
        text.autocapitalizationType = .none
        // 关闭自动修正
        text.autocorrectionType = .no
        // 关闭拼写检查
        text.spellCheckingType = .no
        // 关闭智能引号/破折号
        if #available(iOS 11.0, *) {
            text.smartQuotesType = .no
            text.smartDashesType = .no
        }
        
        text.translatesAutoresizingMaskIntoConstraints = false
        text.addTarget(self, action: #selector(textFieldDidChanged), for: .editingChanged)
        text.delegate = self
        return text
    }
    
    func createTitleLabel(_ title: String) -> UILabel {
        let label = UILabel()
        label.text = title
        label.textColor = .theme.label
        label.themeFont = .theme.title3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    func passwordRules() -> UITextInputPasswordRules {
        return UITextInputPasswordRules(descriptor: "minlength: 8; maxlength: 20; required: lower; required: upper; required: digit; required: [!#%&()*@^~];")
    }
    
    func isValidPassword(_ password: String) -> Bool {
        let pwd = password.trimmingCharacters(in: .whitespacesAndNewlines)
        // 要求：8-20 长度，至少一个小写、至少一个数字。
        // 至少包含一个指定符号：! @ # ¥ % & ( ) * ~ ^
        // 这里同时允许半角 '¥'（U+00A5）和全角 '￥'（U+FFE5）
        let pattern = "^(?=.{8,20}$)(?=.*[a-z])(?=.*\\d)(?=.*[!@#¥￥%&()\\*~\\^]).+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
        return predicate.evaluate(with: pwd)
    }
}

// MARK: - Events

private extension UpdatePasswordController {
    /// 点击了按钮
    private func didClickedCommitButton(_ sender: UIButton) {
        if !checkValidAndNotification() { return }
        postRequest()
    }
    
    /// 本地校验是否有效并提示
    func checkValidAndNotification() -> Bool {
        guard let oldPwd = passwordTextField.text, !oldPwd.isEmpty else {
            if passwordTextField.isFirstResponder {
                feedbackGenerator.notificationOccurred(.warning)
                feedbackGenerator.prepare()
                passwordTextField.defaultShakeAnimation()
            } else {
                passwordTextField.becomeFirstResponder()
            }
            return false
        }
        guard let newPwd1 = newPasswordTextField1.text, !newPwd1.isEmpty else {
            if newPasswordTextField1.isFirstResponder {
                feedbackGenerator.notificationOccurred(.warning)
                feedbackGenerator.prepare()
                newPasswordTextField1.defaultShakeAnimation()
            } else {
                newPasswordTextField1.becomeFirstResponder()
            }
            return false
        }
        guard let newPwd2 = newPasswordTextField2.text, !newPwd2.isEmpty else {
            if newPasswordTextField2.isFirstResponder {
                feedbackGenerator.notificationOccurred(.warning)
                feedbackGenerator.prepare()
                newPasswordTextField2.defaultShakeAnimation()
            } else {
                newPasswordTextField2.becomeFirstResponder()
            }
            return false
        }
        
        guard newPwd1 == newPwd2 else {
            ProgressHUD.showInfo(withStatus: NSLocalizedString("两次输入密码不一致", bundle: .module, comment: ""))
            return false
        }
        
        guard isValidPassword(newPwd1) else {
            ProgressHUD.showInfo(withStatus: descLabel.text)
            return false
        }
        
        return true
    }
    
    /// 本地校验密码是否有效
    func checkPasswordValid() -> Bool {
        guard let oldPwd = passwordTextField.text, !oldPwd.isEmpty else { return false }
        guard let newPwd1 = newPasswordTextField1.text, !newPwd1.isEmpty else { return false }
        guard let newPwd2 = newPasswordTextField2.text, !newPwd2.isEmpty else { return false }
        guard newPwd1 == newPwd2 else { return false }
        return isValidPassword(newPwd1)
    }
}

// MARK: - UITextField

extension UpdatePasswordController: UITextFieldDelegate {
    @objc func textFieldDidChanged(_ textField: UITextField) {
        guard let toString = textField.text else { return }
        
        if textField == newPasswordTextField1 
            || textField == newPasswordTextField2 {
            let maxCount = kMaxPasswordCount
            if toString.count > maxCount {
                textField.text = String(toString.prefix(maxCount))
            }
        }
        
        buttonView.isEnabled = checkPasswordValid()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == usernameTextField {
            return false
        }
        
        guard textField == newPasswordTextField1 || textField == newPasswordTextField2 else {
            return true
        }
        
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        if isValidPassword(updatedText) {
            // 密码有效，执行相应的操作
            textField.textColor = .theme.label
        } else {
            // 密码无效，提示用户
            textField.textColor = .red
        }
        
        return true
    }
}

// MARK: - Network

private extension UpdatePasswordController {
    /// 发起登录请求
    func postRequest() {
        guard let oldPwd = passwordTextField.text, let newPwd = newPasswordTextField1.text else { return }
        guard let encryptedOldPwd = PasswordCrypto.encrypt(oldPwd) else {
            appLog("Encryption failed")
            return
        }
        guard let encryptedNewPwd = PasswordCrypto.encrypt(newPwd) else {
            appLog("Encryption failed")
            return
        }
        
        buttonView.isBusy = true
        buttonView.title = NSLocalizedString("修改中...", bundle: .module, comment: "")
        let target = AccountApi.updatePwd(encryptedOldPwd, encryptedNewPwd)
        ResponseModel<EmptyModel>.requestable(target) {
            [weak self] response, error in
            guard let `self` = self else { return }
            guard error == nil else {
                self.buttonView.isBusy = false
                self.buttonView.title = NSLocalizedString("确认修改", bundle: .module, comment: "")
                ProgressHUD.showError(withStatus: error?.localizedDescription)
                return
            }
            self.buttonView.isBusy = false
            self.buttonView.title = NSLocalizedString("修改成功", bundle: .module, comment: "")
            self.didSubmitPasswordChange = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

