//
//  NormalAlertView.swift
//  Pods
//
//  Created by Janlor on 5/27/24.
//

import UIKit

public class NormalAlertView: UIView {

    // MARK: - UI Elements
    
    private let alertView = UIView()
    private var titleLabel: UILabel?
    private var subTitleLabel: UILabel?
    private let buttonsStackView = UIStackView()
    
    // MARK: - Properties
    
    public var didDismissed: (() -> Void)? = nil
    public var buttonModels: [AlertButtonModel] = []
    
    // MARK: - Initialization
    
    public init(title: String?, subTitle: String?, buttonModels: [AlertButtonModel]) {
        super.init(frame: .zero)
        self.buttonModels = buttonModels
        setupUI(title: title, subTitle: subTitle)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    
    private func setupUI(title: String?, subTitle: String?) {
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        alertView.backgroundColor = UIColor.theme.background
        alertView.applyCapsule(.large)
        alertView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(alertView)
        
        var elements: [UIView] = []
        
        if let title = title {
            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.textColor = .theme.label
            titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
            titleLabel.textAlignment = .center
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            elements.append(titleLabel)
            self.titleLabel = titleLabel
        }
        
        if let subTitle = subTitle {
            let subTitleLabel = UILabel()
            subTitleLabel.text = subTitle
            subTitleLabel.textColor = .darkGray
            subTitleLabel.font = UIFont.systemFont(ofSize: 16)
            subTitleLabel.textAlignment = .center
            subTitleLabel.numberOfLines = 0
            subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
            elements.append(subTitleLabel)
            self.subTitleLabel = subTitleLabel
        }
        
        buttonsStackView.axis = buttonModels.count == 2 ? .horizontal : .vertical
        buttonsStackView.spacing = 10
        buttonsStackView.distribution = .fillEqually
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        for (index, model) in buttonModels.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(model.title, for: .normal)
            button.backgroundColor = model.type.backgroundColor
            button.setTitleColor(model.type.textColor, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            button.applyCapsule(.custom(6))
            button.layer.borderWidth = 0.5
            button.layer.borderColor = model.type.borderColor.cgColor
            button.tag = index
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            buttonsStackView.addArrangedSubview(button)
        }
        elements.append(buttonsStackView)
        
        let stackView = UIStackView(arrangedSubviews: elements)
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        alertView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            alertView.centerXAnchor.constraint(equalTo: centerXAnchor),
            alertView.centerYAnchor.constraint(equalTo: centerYAnchor),
            alertView.widthAnchor.constraint(equalToConstant: 270),
            
            stackView.topAnchor.constraint(equalTo: alertView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: alertView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func buttonTapped(_ sender: UIButton) {
        let index = sender.tag
        dismissAlert {
            self.buttonModels[index].action?()
        }
    }
    
    @objc private func dismissAlert(completion: (() -> Void)? = nil) {
        hiddenAnimate {
            self.didDismissed?()
            completion?()
            self.removeFromSuperview()
        }
    }
    
    // MARK: - Animations
    
    public func show(in view: UIView) {
        view.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topAnchor.constraint(equalTo: view.topAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        showAnimate()
    }
    
    func showAnimate() {
        alertView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        alertView.alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .beginFromCurrentState, animations: {
            self.alertView.transform = CGAffineTransform.identity
            self.alertView.alpha = 1
        }, completion: nil)
    }
    
    private func hiddenAnimate(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .beginFromCurrentState, animations: {
            self.alertView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.alertView.alpha = 0
        }) { _ in
            completion?()
        }
    }
}

