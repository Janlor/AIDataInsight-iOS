//
//  BasePickerView.swift
//  LibraryCommon
//
//  Created by Janlor on 4/22/26.
//

import UIKit

/// 这是一个空壳 请使用其子类
open class BasePickerView: UIView {
    
    open var title: String? {
        didSet {
            titleLabel.text = title ?? " "
        }
    }
    
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    open lazy var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .theme.secondaryGroupedBackground
        view.applyTopRadius(.large)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    open lazy var commitButton: UIButton = {
        var btn = UIButton(type: .system)
        btn.titleLabel?.themeFont = UIFont.theme.title2
        btn.setTitle(NSLocalizedString("确定", bundle: .module, comment: ""), for: .normal)
        btn.setTitleColor(UIColor.theme.accent, for: .normal)
        btn.contentEdgeInsets = UIEdgeInsets(top: 17, left: mSpacing, bottom: 17, right: mSpacing)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(didClickedCommitButton(_:)), for: .touchUpInside)
        return btn
    }()
    
    open lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .theme.label
        label.themeFont = .theme.headline
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    open lazy var cancelButton: UIButton = {
        var btn = UIButton(type: .system)
        btn.titleLabel?.themeFont = UIFont.theme.title2
        btn.setTitle(NSLocalizedString("取消", bundle: .module, comment: ""), for: .normal)
        btn.setTitleColor(UIColor.theme.tertieryLabel, for: .normal)
        btn.contentEdgeInsets = UIEdgeInsets(top: 17, left: mSpacing, bottom: 17, right: mSpacing)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(didClickedCancelButton(_:)), for: .touchUpInside)
        return btn
    }()
    
    // MARK: - Life Cycle
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        addSubviews()
        setupData()
        addGestureRecognizers()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Publics

    open func show() {
        guard let window = UIApplication.shared.appKeyWindow else { return }
        window.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: window.leadingAnchor),
            self.topAnchor.constraint(equalTo: window.topAnchor),
            self.trailingAnchor.constraint(equalTo: window.trailingAnchor),
            self.bottomAnchor.constraint(equalTo: window.bottomAnchor)
        ])
        showAnimate()
    }
    
    open func hidden() {
        guard self.superview != nil else { return }
        hideAnimate { _ in
            self.removeFromSuperview()
        }
    }
    
    // MARK: - Actions
    
    /// 点击了取消按钮
    @objc open func didClickedCancelButton(_ sender: UIButton) {
        hidden()
    }
    
    /// 点击了确定按钮
    @objc open func didClickedCommitButton(_ sender: UIButton) {
        
    }
    
    // MARK: - UI
    
    /// 设置UI
    open func setupUI() {
        backgroundColor = .clear
    }
    
    /// 添加子视图
    open func addSubviews() {
        addSubview(backgroundView)
        addSubview(bottomView)
        bottomView.addSubview(commitButton)
        bottomView.addSubview(cancelButton)
        bottomView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            bottomView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            commitButton.topAnchor.constraint(equalTo: bottomView.topAnchor),
            commitButton.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor),
            
            cancelButton.topAnchor.constraint(equalTo: bottomView.topAnchor),
            cancelButton.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor),
            
            titleLabel.topAnchor.constraint(greaterThanOrEqualTo: bottomView.topAnchor, constant: 17),
            titleLabel.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: cancelButton.trailingAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: commitButton.leadingAnchor)
        ])
        
        commitButton.setContentCompressionResistancePriority(.defaultHigh + 2, for: .horizontal)
        cancelButton.setContentCompressionResistancePriority(.defaultHigh + 1, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultHigh + 1, for: .horizontal)
    }
    
    open func setupData() {
        
    }
    
    private func addGestureRecognizers() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapedBackground(_:)))
        backgroundView.addGestureRecognizer(tap)
    }
    
    @objc func didTapedBackground(_ sender: UITapGestureRecognizer) {
        hidden()
    }
}

private extension BasePickerView {
    func showAnimate() {
        alpha = 0
        bottomView.transform = CGAffineTransform(translationX: 0, y: 276.0)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .beginFromCurrentState) {
            self.alpha = 1.0
            self.bottomView.transform = .identity
        }
    }

    func hideAnimate(completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .beginFromCurrentState) {
            self.alpha = 0
            self.bottomView.transform = CGAffineTransform(translationX: 0, y: self.bottomView.bounds.size.height)
        } completion: { finished in
            if let com = completion {
                com(finished)
            }
        }
    }
}
