//
//  NormalBottomView.swift
//  LibraryCommon
//
//  Created by Janlor on 4/22/26.
//

import UIKit

/// 底部按钮
public class NormalBottomView: UIView {
    
    public typealias DidClicked = ((_ sender: UIButton) -> Void)
    public var didClicked: DidClicked?

    /// 网络请求等情况设置为 true
    public lazy var isBusy = false {
        didSet {
            commitButton.isUserInteractionEnabled = !isBusy
            if #available(iOS 15.0, *) {
                commitButton.setNeedsUpdateConfiguration()
            }
        }
    }
    
    /// 修改标题
    public lazy var title = NSLocalizedString("确认", bundle: .module, comment: "") {
        didSet {
            if #available(iOS 15.0, *) {
                commitButton.setNeedsUpdateConfiguration()
            } else {
                commitButton.setTitle(title, for: .normal)
            }
        }
    }
    
    /// 修改图片
    public var image: UIImage? {
        didSet {
            if #available(iOS 15.0, *) {
                commitButton.setNeedsUpdateConfiguration()
            } else {
                commitButton.setImage(image, for: .normal)
            }
        }
    }
    
    /// 是否可用
    public lazy var isEnabled = true {
        didSet {
            commitButton.isEnabled = isEnabled
        }
    }
    
    private var _commitEdge: UIEdgeInsets?
    public var commitEdge: UIEdgeInsets {
        get {
            if let customEdge = _commitEdge {
                return customEdge
            }
            // 默认值逻辑
            return LiquidGlass.isEnabled ? .zero : UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
        }
        set {
            _commitEdge = newValue
        }
    }
    
    private lazy var commitButton: UIButton = {
        var btn = UIButton(type: .custom)
        if #available(iOS 15.0, *) {
            var config: UIButton.Configuration!
            if #available(iOS 26.0, *), LiquidGlass.isEnabled {
                config = UIButton.Configuration.prominentGlass()
                config.cornerStyle = .capsule
            } else {
                config = UIButton.Configuration.filled()
                config.baseBackgroundColor = .theme.accent
                config.cornerStyle = .medium // 8.0
            }
            config.image = image
            btn = UIButton(configuration: config)
            btn.tintColor = .theme.accent
            btn.configurationUpdateHandler = { [weak self] button in
                guard let `self` = self else { return }
                var conf = button.configuration
                conf?.image = image
                conf?.showsActivityIndicator = self.isBusy
                var attributedTitle = AttributedString(self.title)
                attributedTitle.font = UIFont.theme.title2
                conf?.attributedTitle = attributedTitle
                button.configuration = conf
            }
        } else {
            btn.setTitle(title, for: .normal)
            btn.setTitleColor(.white, for: .normal)
            btn.titleLabel?.themeFont = UIFont.theme.title2
            btn.setBackgroundImage(backgroundImage, for: .normal)
            btn.applyCorner(.medium)
        }
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(didClickedCommitButton(_:)), for: .touchUpInside)
        return btn
    }()
    
    private lazy var backgroundImage: UIImage? = {
        let image = UIImage.gradientImage(colors: [
            UIColor(appHex: 0xF9394B),
            UIColor(appHex: 0xE4222B),
            UIColor(appHex: 0xD7000F)
        ], locations: [0, 0.3, 1], startPoint: CGPoint(x: 0, y: 0.21), endPoint: CGPoint(x: 0.75, y: 0.75), size: CGSize(width: 343, height: 44))
        return image
    }()

    public init(commitEdge: UIEdgeInsets) {
        super.init(frame: .zero)
        self.commitEdge = commitEdge
        setupUI()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {        
        addSubview(commitButton)
        
        let top = commitButton.topAnchor.constraint(equalTo: topAnchor, constant: commitEdge.top)
        top.isActive = true
        top.priority = .required - 1 // 消除警告
        NSLayoutConstraint.activate([
            commitButton.leadingAnchor.constraint(equalTo: readableContentGuide.leadingAnchor, constant: commitEdge.left),
            commitButton.trailingAnchor.constraint(equalTo: readableContentGuide.trailingAnchor, constant: -commitEdge.right),
            commitButton.heightAnchor.constraint(equalToConstant: 44.0)
        ])
        
        if LiquidGlass.isEnabled {
            backgroundColor = .clear
            NSLayoutConstraint.activate([
                commitButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -commitEdge.bottom),
            ])
        } else {
            NSLayoutConstraint.activate([
                commitButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -commitEdge.bottom),
            ])
        }
    }
    
    /// 点击了保存按钮
    @objc private func didClickedCommitButton(_ sender: UIButton) {
        if let didClicked = didClicked {
            didClicked(sender)
        }
    }
    
}
