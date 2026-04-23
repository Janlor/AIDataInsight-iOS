//
//  AIChatWelcomeCell.swift
//  ModuleAI
//
//  Created by Janlor on 4/22/26.
//

import UIKit
import BaseKit
import BaseUI

protocol AIChatWelcomeCellDelegate: AnyObject {
    func chatWelcomeCell(_ cell: AIChatWelcomeCell, didTapText text: String)
}

class AIChatWelcomeCell: AIChatCell {
    weak var delegate: AIChatWelcomeCellDelegate?
    
    var questions: [String]? {
        didSet {
            viewManager.setupModels(questions)
        }
    }
    
    private lazy var containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.alignment = .fill
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var exampleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .theme.label
        label.themeFont = .theme.subhead
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var exampleStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .fill
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var exampleView1: AIChatWelcomeExampleView = AIChatWelcomeExampleView(top: "今年第一季度", bottom: "时间范围")
    private lazy var exampleView2: AIChatWelcomeExampleView = AIChatWelcomeExampleView(top: "销售额", bottom: "指标名称")
    private lazy var exampleView3: AIChatWelcomeExampleView = AIChatWelcomeExampleView(top: "大于5000万", bottom: "过滤条件")
    private lazy var exampleView4: AIChatWelcomeExampleView = AIChatWelcomeExampleView(top: "的", bottom: " ", isTopRegular: true)
    private lazy var exampleView5: AIChatWelcomeExampleView = AIChatWelcomeExampleView(top: "公司。", bottom: "分组维度")

    private var viewManager: DynamicViewManager<String, AIChatWelcomeQuestionView>!
    
    override func setupViews() {
        super.setupViews()
        messageLabelBottom.isActive = false
        
        bubbleView.addSubview(containerStackView)
        bubbleView.addSubview(exampleLabel)
        bubbleView.addSubview(exampleStackView)
        
        exampleStackView.addArrangedSubview(exampleView1)
        exampleStackView.addArrangedSubview(exampleView2)
        exampleStackView.addArrangedSubview(exampleView3)
        exampleStackView.addArrangedSubview(exampleView4)
        exampleStackView.addArrangedSubview(exampleView5)
        
        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: contentEdge.left),
            containerStackView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -contentEdge.right),

            exampleLabel.topAnchor.constraint(equalTo: containerStackView.bottomAnchor, constant: 16),
            exampleLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: contentEdge.left),
            exampleLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -contentEdge.right),

            exampleStackView.topAnchor.constraint(equalTo: exampleLabel.bottomAnchor, constant: 12),
            exampleStackView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: contentEdge.left),
            exampleStackView.trailingAnchor.constraint(lessThanOrEqualTo: bubbleView.trailingAnchor, constant: -contentEdge.right),
        ])
        
        let bottomLayout = exampleStackView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -18)
        bottomLayout.priority = .required - 1 // 消除警告
        bottomLayout.isActive = true
        
        viewManager = DynamicViewManager(container: containerStackView,
                                         createView: createChildView,
                                         setupView: setupChildView(_:_:),
                                         extraSetup: extraSetupView(_:_:))
    }
    
    override func setupData() {
        super.setupData()
        let richText: [AIChatRichText] = [
            AIChatRichText(text: "你好，我是你的AI数据分析助手。我能根据"),
            AIChatRichText(text: "业绩、库存、代采、应收、帐龄").bold,
            AIChatRichText(text: "等领域的问题生成相应的智能图表。\n你也可以尝试点击以下推荐问题：")
        ]
        
        let attributedString = AIChatRichText.attributedString(from: richText)
        messageLabel.attributedText = attributedString

        let example = AIChatRichText(text: "我能精准识别问题中的指标名称、时间范围、分组维度和过滤条件，例如：")
        exampleLabel.attributedText = AIChatRichText.attributedString(from: [example])
    }
}

extension AIChatWelcomeCell {
    private func createChildView() -> AIChatWelcomeQuestionView {
        let view = AIChatWelcomeQuestionView()
        view.didClicked = { [weak self] sender, index in
            guard let `self` = self else { return }
            guard let questions = self.questions, index < questions.count else { return }
            self.delegate?.chatWelcomeCell(self, didTapText: questions[index])
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private func setupChildView(_ view: AIChatWelcomeQuestionView, _ model: String) {
        view.configure(with: model)
    }
    
    private func extraSetupView(_ view: AIChatWelcomeQuestionView, _ index: Int) {
        view.tag = index
    }
}

class AIChatWelcomeQuestionView: UIView {
    public typealias DidClicked = ((_ sender: ClickableLabel, _ index: Int) -> Void)
    public var didClicked: DidClicked?
    
    private lazy var textLabel: ClickableLabel = {
        let view = ClickableLabel()
        view.themeFont = .theme.subhead
        view.normalTextColor = UIColor.aiAccent
        view.highlightTextColor = UIColor.aiAccent.withAlphaComponent(0.4)
        view.textColor = view.normalTextColor
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        view.didClicked = { [weak self] sender in
            self?.didClicked?(sender, self?.tag ?? 0)
        }
        return view
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .theme.separator
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(textLabel)
        addSubview(separatorView)

        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
        ])
        
        let bottomLayout = textLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -9)
        bottomLayout.priority = .required - 1 // 消除警告
        bottomLayout.isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with text: String) {
        textLabel.text = text
    }
}

class AIChatWelcomeExampleView: UIStackView {

    let topLabel: UILabel = {
        let label = UILabel()
        label.textColor = .theme.label
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let bottomLabel: UILabel = {
        let label = UILabel()
        label.textColor = .theme.tertieryLabel
        label.font = UIFont.systemFont(ofSize: 10)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init(top: String, bottom: String, isTopRegular: Bool = false) {
        super.init(frame: .zero)
        
        alignment = .center
        axis = .vertical
        spacing = 4

        addArrangedSubview(topLabel)
        addArrangedSubview(bottomLabel)

        topLabel.text = top
        bottomLabel.text = bottom
        
        if isTopRegular {
            topLabel.font = UIFont.systemFont(ofSize: 12)
        } else {
            topLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        }
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
