//
//  LoginViewController.swift
//  LibraryCommon
//
//  Created by Janlor on 2024/5/29.
//

import UIKit
import PrivacyProtocol
import BaseUI
import Router
import BaseEnv
import Environment

class LoginViewController: BaseViewController {
    /// 最大账号长度
    private let kMaxUsernameCount = 30
    /// 最大密码长度
    private let kMaxPasswordCount = 30
    
    /// 交互震动反馈
    private lazy var notificationFeedback: UINotificationFeedbackGenerator = {
        let gen = UINotificationFeedbackGenerator()
        gen.prepare()
        return gen
    }()
    private lazy var selectionFeedback: UISelectionFeedbackGenerator = {
        let feedback = UISelectionFeedbackGenerator()
        feedback.prepare()
        return feedback
    }()
    
    /// scrollView
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView.init()
        scroll.isScrollEnabled = true
        scroll.alwaysBounceVertical = true
        scroll.keyboardDismissMode = .onDrag
        return scroll
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var iconImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.applyCorner(.medium)
        view.backgroundColor = .theme.secondaryGroupedBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .theme.label
        label.themeFont = .theme.largeTitle
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var sloganLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("让工作更流畅更轻松", bundle: .module, comment: "")
        label.textColor = .theme.secondaryLabel
        label.themeFont = .theme.subhead
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// 账号输入框
    private lazy var usernameTextField: UITextField = {
        let text = createTextField(NSLocalizedString("请输入账号", bundle: .module, comment: ""))
        text.textContentType = .username
        text.themeFont = UIFont.systemFont(ofSize: 16, weight: .bold)
        return text
    }()
    
    private lazy var separatorView1: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.theme.separator
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var passwordTextField: UITextField = {
        let text = createTextField(NSLocalizedString("请输入密码", bundle: .module, comment: ""))
        text.textContentType = .password
        text.isSecureTextEntry = true
        text.themeFont = UIFont.systemFont(ofSize: 16, weight: .bold)
        return text
    }()
    
    private lazy var separatorView2: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.theme.separator
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var checkBoxButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage.imageNamed(for: "check_box_normal"), for: .normal)
        btn.setImage(UIImage.imageNamed(for: "check_box_selected"), for: .selected)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.contentEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        btn.addTarget(self, action: #selector(didClickedCheckBoxButton(_:)), for: .touchUpInside)
        return btn
    }()
    
    private lazy var checkTextView: UITextView = {
        let view = UITextView()
        let text = NSLocalizedString("已阅读并同意《隐私政策》", bundle: .module, comment: "")
        let attributedString = NSMutableAttributedString(string: text)
        for (key, value) in linkDict {
            guard let range = text.range(of: key) else { continue }
            let nsRange = NSRange(range, in: text)
            attributedString.addAttribute(.link, value: value, range: nsRange)
        }
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.theme.secondaryLabel,
            .font: UIFont.theme.subhead
        ]
        attributedString.addAttributes(attributes, range: NSRange(location: 0, length: text.count))
        view.attributedText = attributedString
        view.linkTextAttributes = [.foregroundColor: UIColor.theme.accent]
        view.delegate = self
        view.isEditable = false
        view.isScrollEnabled = false
        view.backgroundColor = .clear
        view.layoutManager.allowsNonContiguousLayout = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var buttonView: NormalBottomView = {
        let view = NormalBottomView()
        view.title = NSLocalizedString("登录", bundle: .module, comment: "")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.didClicked = { [weak self] sender in
            self?.didClickedLoginButton(sender)
        }
        view.isEnabled = false // 默认不可用
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var linkDict: [String: String] = {
        return [NSLocalizedString("《隐私政策》", bundle: .module, comment: ""): Environment.server.privacyPolicyURL]
    }()

    private let viewModel = LoginViewModel()
    private var loginTask: Task<Void, Never>?
    
    // MARK: - Life Cycle

    override func setupUI() {
        super.setupUI()
        setupBackground()
        addSubviews()
        addGestureRecognizer()
        addNotifications()
        bindViewModel()
        
        scrollView.contentInsetAdjustmentBehavior = .never
        view.backgroundColor = .theme.background
        navigationItem.backButtonTitle = NSLocalizedString("登录", bundle: .module, comment: "")
    }
    
    override func setupData() {
        super.setupData()
        
        switch CommonTarget.target {
        default:
            iconImageView.image = UIImage.imageNamed(for: "Login_icon")
            titleLabel.text = NSLocalizedString("AI数据分析助手", bundle: .module, comment: "")
        }
        
        // 演示账号
        usernameTextField.text = "demo"
        passwordTextField.text = "demo@123"
        checkBoxButton.isSelected = true
        textFieldDidChanged(passwordTextField)
    }

    deinit {
        loginTask?.cancel()
        NotificationCenter.default.removeObserver(self)
    }
}

private extension LoginViewController {
    func bindViewModel() {
        viewModel.onLoadingStateChange = { [weak self] isLoading in
            self?.requestLock(isLoading)
        }
        viewModel.onError = { message in
            ProgressHUD.showError(withStatus: message)
        }
    }

    /// 添加子视图
    func addSubviews() {
        let margin: CGFloat = 38.0
        
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor, constant: 1.0)
        ])
        
        contentView.addSubview(iconImageView)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
        
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: margin),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -margin),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
        
        contentView.addSubview(sloganLabel)
        sloganLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sloganLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            sloganLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
        
        contentView.addSubview(separatorView1)
        separatorView1.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            separatorView1.leadingAnchor.constraint(equalTo: contentView.readableContentGuide.leadingAnchor, constant: margin - 8.0),
            separatorView1.trailingAnchor.constraint(equalTo: contentView.readableContentGuide.trailingAnchor, constant: -margin + 8.0),
            separatorView1.topAnchor.constraint(equalTo: sloganLabel.bottomAnchor, constant: 105.0),
            separatorView1.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        contentView.addSubview(separatorView2)
        separatorView2.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            separatorView2.leadingAnchor.constraint(equalTo: separatorView1.leadingAnchor),
            separatorView2.trailingAnchor.constraint(equalTo: separatorView1.trailingAnchor),
            separatorView2.topAnchor.constraint(equalTo: separatorView1.bottomAnchor, constant: 20.0 + 45),
            separatorView2.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        contentView.addSubview(usernameTextField)
        usernameTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            usernameTextField.leadingAnchor.constraint(equalTo: separatorView1.leadingAnchor),
            usernameTextField.trailingAnchor.constraint(equalTo: separatorView1.trailingAnchor),
            usernameTextField.bottomAnchor.constraint(equalTo: separatorView1.topAnchor),
            usernameTextField.heightAnchor.constraint(equalToConstant: 45.0)
        ])
        
        contentView.addSubview(passwordTextField)
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            passwordTextField.leadingAnchor.constraint(equalTo: separatorView2.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: separatorView2.trailingAnchor),
            passwordTextField.bottomAnchor.constraint(equalTo: separatorView2.topAnchor),
            passwordTextField.heightAnchor.constraint(equalToConstant: 45.0)
        ])
        
        contentView.addSubview(buttonView)
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonView.leadingAnchor.constraint(equalTo: contentView.readableContentGuide.leadingAnchor, constant: 22.0 - 8.0),
            buttonView.trailingAnchor.constraint(equalTo: contentView.readableContentGuide.trailingAnchor, constant: -22.0 + 8.0),
            buttonView.topAnchor.constraint(equalTo: separatorView2.bottomAnchor, constant: 30.0),
        ])
        
        // 居中布局
        buttonView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 110).isActive = true
        
        contentView.addSubview(checkTextView)
        contentView.addSubview(checkBoxButton)
        NSLayoutConstraint.activate([
            checkTextView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -22.0),
            checkTextView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 10.0),
            checkTextView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            checkBoxButton.trailingAnchor.constraint(equalTo: checkTextView.leadingAnchor, constant: 11),
            checkBoxButton.centerYAnchor.constraint(equalTo: checkTextView.centerYAnchor),
            checkBoxButton.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 22.0),
        ])
        
        checkBoxButton.setContentCompressionResistancePriority(.defaultHigh + 1, for: .horizontal)
        checkTextView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    
    func createTextField(_ placeholder: String) -> UITextField {
        let text = UITextField()
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.theme.subhead,
            .foregroundColor: UIColor.theme.quaternaryLabel
        ]
        text.attributedPlaceholder = NSAttributedString.init(string: placeholder, attributes: attributes)
        text.textColor = UIColor.theme.label
        text.clearButtonMode = .whileEditing
        text.returnKeyType = .done
        text.delegate = self
        // 禁用拼写检查和自动纠正
        text.autocapitalizationType = .none
        text.autocorrectionType = .no
        text.spellCheckingType = .no
        text.addTarget(self, action: #selector(textFieldDidChanged), for: .editingChanged)
        return text
    }
}

private extension LoginViewController {
    func addGestureRecognizer() {
        guard EnvInfo.env != .appStore && EnvInfo.env != .pre else {
            return
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapedIconImageView(_:)))
        tap.numberOfTapsRequired = 2
        iconImageView.addGestureRecognizer(tap)
        iconImageView.isUserInteractionEnabled = true
    }
    
    @objc func didTapedIconImageView(_ sender: UITapGestureRecognizer) {
        // 过滤函数，排除当前环境、未知环境、生产环境
        func environmentFilter(_ env: EnvInfo.EnvType) -> Bool {
            return env != EnvInfo.env
        }
        
        let environmentDescription: [EnvInfo.EnvType: String] = [
            .dev: "开发环境(0.83:18037)",
            .sit: "测试环境(4.79:17037)",
            .uat: "测试环境(4.60:17037)",
            .staging: "预发布环境(3.88:16037)"
        ]
        
        let allOptions: [EnvInfo.EnvType] = [.dev, .sit, .uat, .staging]
        let options: [EnvInfo.EnvType] = allOptions.filter(environmentFilter)
        let title = environmentDescription[EnvInfo.env]
        
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        alert.view.tintColor = .theme.label
        options.forEach { env in
            alert.addAction(UIAlertAction(title: environmentDescription[env], style: .default,handler: { _ in
                EnvInfo.switchEnv(to: env)
            }))
        }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        if let popover = alert.popoverPresentationController {
            popover.sourceView = sender.view
        }
        
        presentToVC(alert)
    }
    
    @objc func didClickedCheckBoxButton(_ sender: UIButton) {
        sender.isSelected.toggle()
        selectionFeedback.selectionChanged()
        selectionFeedback.prepare()
    }
}

private extension LoginViewController {
    func addNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onAuthFailed),
            name: .authFailed,
            object: nil
        )
    }
    
    @objc private func onAuthFailed(noti: Notification) {
        requestLock(false)
        
        if let obj = noti.object as? Set<String>, !obj.isEmpty {
            let msg = obj.joined(separator: "\n")
            ProgressHUD.showError(withStatus: msg)
        }
    }
}

// MARK: - Events

private extension LoginViewController {
    /// 点击了登录按钮
    @objc private func didClickedLoginButton(_ sender: UIButton) {
        if !checkUsernameValid() { return }
        if !checkPasswordValid() { return }
        if !checkPrivacPolicyValid() { return }
        postLoginRequest()
    }
    
    /// 本地校验账号是否有效并提示
    func checkUsernameValid() -> Bool {
        guard let username = usernameTextField.text, !username.isEmpty else {
            if usernameTextField.isFirstResponder {
                notificationFeedback.notificationOccurred(.warning)
                notificationFeedback.prepare()
                usernameTextField.defaultShakeAnimation()
            } else {
                usernameTextField.becomeFirstResponder()
            }
            return false
        }
        return true
    }
    
    /// 本地校验密码是否有效并提示
    func checkPasswordValid() -> Bool {
        guard let pwd = passwordTextField.text, !pwd.isEmpty else {
            if passwordTextField.isFirstResponder {
                notificationFeedback.notificationOccurred(.warning)
                notificationFeedback.prepare()
                passwordTextField.defaultShakeAnimation()
            } else {
                passwordTextField.becomeFirstResponder()
            }
            return false
        }
        return true
    }
    
    /// 校验隐私协议是否勾选并提示
    func checkPrivacPolicyValid() -> Bool {
        guard !checkBoxButton.isSelected else {
            return true
        }
        view.endEditing(true)
        notificationFeedback.notificationOccurred(.warning)
        notificationFeedback.prepare()
        checkBoxButton.defaultShakeAnimation()
        checkTextView.defaultShakeAnimation()
        return false
    }
}

// MARK: - UITextField

extension LoginViewController: UITextFieldDelegate {
    @objc func textFieldDidChanged(_ textField: UITextField) {
        guard let toString = textField.text else { return }
        
        if textField == usernameTextField {
            let maxCount = kMaxUsernameCount
            if toString.count > maxCount {
                textField.text = String(toString.prefix(maxCount))
            }
        } else if textField == passwordTextField {
            let maxCount = kMaxPasswordCount
            if toString.count > maxCount {
                textField.text = String(toString.prefix(maxCount))
            }
        }
        
        if let username = usernameTextField.text,
           let password = passwordTextField.text {
            buttonView.isEnabled = (!username.isEmpty && !password.isEmpty)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameTextField {
            if passwordTextField.text == nil || passwordTextField.text!.isEmpty {
                passwordTextField.becomeFirstResponder()
            } else {
                textField.resignFirstResponder()
            }
        }
        
        if textField == passwordTextField {
            textField.resignFirstResponder()
        }
        
        if buttonView.isEnabled {
            didClickedLoginButton(UIButton())
        }
        
        return true
    }
}

// MARK: - UITextViewDelegate

extension LoginViewController: UITextViewDelegate {
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let urlString = URL.absoluteString
        if linkDict.values.contains(urlString) {
            Router.push(from: self, to: PrivacyProtocol.self, animated: true)?
                .insert(params: ["urlString": urlString])
            return false
        }
        return true
    }
}

// MARK: - Network

private extension LoginViewController {
    /// 发起登录请求
    func postLoginRequest() {
        guard let username = usernameTextField.text,
              let password = passwordTextField.text else {
            return
        }

        loginTask?.cancel()
        loginTask = Task { [weak self] in
            guard let self else {
                return
            }
            await viewModel.login(username: username, password: password)
        }
    }
    
    func requestLock(_ start: Bool) {
        buttonView.title = start ? NSLocalizedString("登录中…", bundle: .module, comment: "") : NSLocalizedString("登录", bundle: .module, comment: "")
        buttonView.isBusy = start
        usernameTextField.isUserInteractionEnabled = !start
        passwordTextField.isUserInteractionEnabled = !start
    }
}
