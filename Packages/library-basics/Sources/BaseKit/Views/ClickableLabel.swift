//
//  ClickableLabel.swift
//  LibraryBasics
//
//  Created by Janlor on 4/22/26.
//

import UIKit

public class ClickableLabel: UILabel {
    public typealias DidClicked = ((_ sender: ClickableLabel) -> Void)
    public var didClicked: DidClicked?
    
    // 高亮颜色
    public var highlightTextColor: UIColor = UIColor.lightGray
    // 原始颜色
    public var normalTextColor: UIColor = UIColor.clear {
        didSet { self.textColor = normalTextColor }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        self.isUserInteractionEnabled = true
        self.textColor = normalTextColor
        
        // 添加点击手势识别器
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.delaysTouchesBegan = false // 关键设置：不延迟触摸事件
        tapGesture.delaysTouchesEnded = false // 关键设置：不延迟触摸结束事件
        self.addGestureRecognizer(tapGesture)
    }

    // 保留触摸事件以实现高亮效果
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.textColor = highlightTextColor
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.textColor = normalTextColor
    }

    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.textColor = normalTextColor
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            labelTapped()
        }
    }

    // 点击事件处理
    private func labelTapped() {
        didClicked?(self)
    }
}
