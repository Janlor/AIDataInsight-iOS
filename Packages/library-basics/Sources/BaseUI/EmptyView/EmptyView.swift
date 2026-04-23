//
//  EmptyView.swift
//  UIToolS
//
//  Created by Janlor on 4/22/26.
//

import UIKit

public enum EmptyViewState: Int {
    case idle = 0
    case loading
    case empty
    case error
}

open class EmptyView: UIStackView {
    public var retryTitle: String? = NSLocalizedString("重试", bundle: .module, comment: "") {
        didSet {
            retryButton.setTitle(retryTitle, for: .normal)
        }
    }
    
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let imageView = UIImageView()
    private let messageLabel = UILabel()
    private let retryButton = UIButton(type: .system)
    
    public var retryCallback: ((UIButton) -> Void)?
    
    private var currentState: EmptyViewState = .loading
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required public init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        axis = .vertical
        spacing = 8
        alignment = .center
        
        activityIndicator.tintColor = .theme.tertieryLabel
        
        imageView.tintColor = .theme.tertieryLabel
        
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.themeFont = .theme.caption1
        messageLabel.textColor = .theme.tertieryLabel
        
        retryButton.setTitle(retryTitle, for: .normal)
        retryButton.addTarget(self, action: #selector(didClickedRetryButton(_:)), for: .touchUpInside)
        
        addArrangedSubview(activityIndicator)
        addArrangedSubview(imageView)
        addArrangedSubview(messageLabel)
        addArrangedSubview(retryButton)
    }
    
    @objc private func didClickedRetryButton(_ sender: UIButton) {
        retryCallback?(sender)
    }
        
    public func setState(_ state: EmptyViewState, message: String? = nil, image: UIImage? = nil, imgSize: CGSize? = nil) {
        switch state {
        case .idle:
            activityIndicator.stopAnimating()
            messageLabel.text = nil
            messageLabel.isHidden = true
            imageView.isHidden = true
            retryButton.isHidden = true
        case .loading:
            activityIndicator.startAnimating()
            messageLabel.text = message
            messageLabel.isHidden = false
            imageView.isHidden = true
            retryButton.isHidden = true
            animateView(show: activityIndicator, messageLabel, delay: 0.5)
        case .empty:
            activityIndicator.stopAnimating()
            messageLabel.text = message
            imageView.image = image
            messageLabel.isHidden = false
            imageView.isHidden = false
            retryButton.isHidden = true
            animateView(show: imageView, messageLabel)
        case .error:
            activityIndicator.stopAnimating()
            messageLabel.text = message
            imageView.image = image
            messageLabel.isHidden = false
            imageView.isHidden = false
            retryButton.isHidden = retryTitle == nil
            animateView(show: imageView, messageLabel, retryButton)
        }
        
        if imageView.isHidden == false, let imgSize = imgSize {
            imageView.widthAnchor.constraint(equalToConstant: imgSize.width).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: imgSize.height).isActive = true
        }
    }
    
    private func animateView(show views: UIView..., delay: TimeInterval = 0) {
        views.forEach { $0.alpha = 0 }
        
        UIView.animate(withDuration: 0.3, delay: delay) {
            views.forEach { $0.alpha = 1 }
        }
    }
}
