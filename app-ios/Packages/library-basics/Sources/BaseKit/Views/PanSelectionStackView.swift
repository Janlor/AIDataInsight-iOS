//
//  PanSelectionStackView.swift
//  LibraryBasics
//
//  Created by Janlor on 5/31/24.
//

import UIKit
import AudioToolbox.AudioServices

public class PanSelectionStackView: UIStackView {

    // MARK: - Properties

    private lazy var feedbackGenerator: UISelectionFeedbackGenerator = {
        let feedback = UISelectionFeedbackGenerator()
        feedback.prepare()
        return feedback
    }()
    private var highlightedButton: UIButton?

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        addPanGesture()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        addPanGesture()
    }

    // MARK: - Gesture

    private func addPanGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panAction(_:)))
        addGestureRecognizer(pan)
    }

    // MARK: - Actions

    @objc private func panAction(_ pan: UIPanGestureRecognizer) {
        if pan.state == .began || pan.state == .changed {
            let location = pan.location(in: self)
            var findButton: UIButton?
            
            for view in arrangedSubviews {
                if let button = view as? UIButton {
                    let buttonPoint = button.convert(location, from: self)
                    if button.point(inside: buttonPoint, with: nil) {
                        button.isHighlighted = true
                        button.sendActions(for: .touchDown)
                        findButton = button
                        break
                    }
                }
            }
            setupHighlightedButton(findButton)
            return
        }

        if pan.state == .ended || pan.state == .cancelled {
            for view in arrangedSubviews {
                if let button = view as? UIButton, button.isHighlighted {
                    button.sendActions(for: .touchUpInside)
                    button.isHighlighted = false
                    break
                }
            }
        }
    }

    private func selectionChanged() {
        // 播放声音
        AudioServicesPlaySystemSound(1104) // 1104 对应于 `Tock.aiff`
        feedbackGenerator.selectionChanged()
        feedbackGenerator.prepare()
    }

    // MARK: - Setters

    private func setupHighlightedButton(_ btn: UIButton?) {
        let isEqual = highlightedButton == btn
        
        if highlightedButton != nil && btn != nil && !isEqual {
            selectionChanged()
        }
        
        if !isEqual {
            highlightedButton?.isHighlighted = false
        }
        
        if let highButton = btn {
            highlightedButton = highButton
        }
    }
}
