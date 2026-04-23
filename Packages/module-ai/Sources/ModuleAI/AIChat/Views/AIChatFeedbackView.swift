//
//  AIChatFeedbackView.swift
//  ModuleAI
//
//  Created by Janlor on 4/22/26.
//

import UIKit
import BaseUI

class AIChatFeedbackView: UIView {
    var likeAction: ((UIButton) -> Void)?
    var unLikeAction: ((UIButton) -> Void)?

    var isLike: Bool? {
        didSet {
            guard let isLike = isLike else { return }
            likeButton.isSelected = isLike
            unLikeButton.isSelected = !isLike
        }
    }

    private let likeButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage.imageNamed(for: "like_normal"), for: .normal)
        let selectedImage = UIImage.imageNamed(for: "like_selected")
        btn.setImage(selectedImage, for: .selected)
        btn.setImage(selectedImage, for: [.highlighted, .selected])
        btn.contentEdgeInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 12)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let unLikeButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage.imageNamed(for: "unlike_normal"), for: .normal)
        let selectedImage = UIImage.imageNamed(for: "unlike_selected")
        btn.setImage(selectedImage, for: .selected)
        btn.setImage(selectedImage, for: [.highlighted, .selected])
        btn.contentEdgeInsets = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 16)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .theme.separator
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }  

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard let previousTraitCollection = previousTraitCollection else { return }
        if (previousTraitCollection.hasDifferentColorAppearance(comparedTo: traitCollection)) {
            layer.borderColor = UIColor.aiSeparator.cgColor
        }
    }
    
    func setupViews() {
        layer.borderColor = UIColor.aiSeparator.cgColor
        layer.borderWidth = 1
        applyCapsule(.custom(15))

        likeButton.addTarget(self, action: #selector(didClickedLikeButton(_:)), for: .touchUpInside)
        unLikeButton.addTarget(self, action: #selector(didClickedUnLikeButton(_:)), for: .touchUpInside)

        addSubview(likeButton)
        addSubview(unLikeButton)
        addSubview(separatorView)

        NSLayoutConstraint.activate([
            likeButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            likeButton.topAnchor.constraint(equalTo: topAnchor),
            likeButton.bottomAnchor.constraint(equalTo: bottomAnchor),

            unLikeButton.leadingAnchor.constraint(equalTo: likeButton.trailingAnchor),
            unLikeButton.topAnchor.constraint(equalTo: topAnchor),
            unLikeButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            unLikeButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            likeButton.widthAnchor.constraint(equalTo: unLikeButton.widthAnchor, multiplier: 1),

            separatorView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            separatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            separatorView.widthAnchor.constraint(equalToConstant: 1),
        ])
    }

    @objc func didClickedLikeButton(_ sender: UIButton) {
        guard !sender.isSelected else { return }
        sender.isSelected = true
        unLikeButton.isSelected = false
        likeAction?(sender)
    }

    @objc private func didClickedUnLikeButton(_ sender: UIButton) {
        guard !sender.isSelected else { return }
        sender.isSelected = true
        likeButton.isSelected = false
        unLikeAction?(sender)
    }
}
