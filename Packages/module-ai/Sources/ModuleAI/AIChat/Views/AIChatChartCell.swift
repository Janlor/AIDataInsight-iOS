//
//  AIChatChartCell.swift
//  ModuleAI
//
//  Created by Janlor on 4/22/26.
//

import UIKit
import BaseUI
import DGCharts

protocol AIChatChartCellDelegate: AnyObject {
    func chatChartCell(_ cell: AIChatChartCell, didTapFeedback sender: UIButton, like: String, historyDetailId: Int?)
}

class AIChatChartCell: AIChatCell {
    weak var delegate: AIChatChartCellDelegate?

    public var chatModel: AIChat? {
        didSet { setupData() }
    }
    
    private let maxVisibleCount = 7
    private var hasInitialLayout = false
    
    lazy var chartStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = verSpacing
        stack.alignment = .fill
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var unitLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.textColor = .theme.tertieryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var chartView: BarChartView = {
        let chartView = BarChartView()
        chartView.highlightFullBarEnabled = true
        chartView.renderer = AIBarChartRenderer(dataProvider: chartView, animator: chartView.chartAnimator, viewPortHandler: chartView.viewPortHandler)
        chartView.setupChart()
        chartView.setupBarLineChart()
        chartView.setupBarChart()
        chartView.translatesAutoresizingMaskIntoConstraints = false
        return chartView
    }()
    private var chartViewHeight: NSLayoutConstraint!
    private let defaultChartHeight: CGFloat = 205
    
    private lazy var feedbackView: AIChatFeedbackView = {
        let view = AIChatFeedbackView(frame: .zero)
        view.backgroundColor = .theme.secondaryGroupedBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var calcHeightLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard !hasInitialLayout,
              let data = chartView.data,
              data.entryCount > maxVisibleCount else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            let count = Double(self.maxVisibleCount)
            self.chartView.setVisibleXRangeMaximum(count)
            self.chartView.setVisibleXRangeMinimum(count)
            self.chartView.zoom(scaleX: 1.0, scaleY: 1.0, x: 0, y: 0)
            self.chartView.moveViewToX(0)
            self.hasInitialLayout = true
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // cell 重用时重置标记
        hasInitialLayout = false
    }
    
    override func setupViews() {
        super.setupViews()
        messageLabelBottom.isActive = false
        bubbleViewBottom.isActive = false

        bubbleView.addSubview(chartStackView)
        chartStackView.addArrangedSubview(unitLabel)
        chartStackView.addArrangedSubview(chartView)
        contentView.addSubview(feedbackView)
        
        chartStackView.setCustomSpacing(0, after: unitLabel)
        
        chartViewHeight = chartView.heightAnchor.constraint(equalToConstant: defaultChartHeight)
        NSLayoutConstraint.activate([
            chartStackView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: verSpacing),
            chartStackView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: contentEdge.left),
            chartStackView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -contentEdge.right),
            chartStackView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -16),
            
            chartViewHeight,
            
            feedbackView.topAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: verSpacing),
            feedbackView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor),
        ])
        
        let bottomLayout = feedbackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -verSpacing)
        bottomLayout.priority = .required - 1 // 消除警告
        bottomLayout.isActive = true
        
        setupFeedbackView()
    }
    
    override func updateViews() {
        super.updateViews()
        bubbleViewTrailing?.isActive = false
        bubbleViewTrailing = bubbleView.trailingAnchor.constraint(equalTo: contentView.readableContentGuide.trailingAnchor, constant: -(mSpacing + ltSpacing) + 8.0)
        bubbleViewTrailing?.isActive = true
    }
    
    override func setupData() {
        super.setupData()
        
        let text = chatModel?.text ?? ""
        let richText = AIChatRichText(text: text, attributes: [
            .foregroundColor: UIColor.theme.label,
            .font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ])
        messageLabel.attributedText = AIChatRichText.attributedString(from: [richText])
        
        updateChartData()
        
        if let isLike = chatModel?.isLike {
            feedbackView.isLike = isLike
        } else {
            feedbackView.isLike = nil
        }
    }
    
    func setupFeedbackView() {
        feedbackView.likeAction = { [weak self] sender in
            guard let `self` = self else { return }
            self.chatModel?.isLike = true
            self.delegate?.chatChartCell(self, didTapFeedback: sender, like: "1", historyDetailId: chatModel?.historyDetailId)
        }

        feedbackView.unLikeAction = { [weak self] sender in
            guard let `self` = self else { return }
            self.chatModel?.isLike = false
            self.delegate?.chatChartCell(self, didTapFeedback: sender, like: "0", historyDetailId: chatModel?.historyDetailId)
        }
    }
    
    func updateChartMarker(_ count: Int?) {
        let shouldShowMarker = count ?? 0 <= 1
        if shouldShowMarker && chartView.marker == nil {
            let marker = XYMarkerView(color: .theme.tertieryGroupedBackground,
                                      font: .theme.caption1,
                                      textColor: .theme.label,
                                      insets: UIEdgeInsets(top: 8, left: 8, bottom: 16, right: 8),
                                      xAxisValueFormatter: chartView.xAxis.valueFormatter!,
                                      unit: chatModel?.unitString)
            marker.chartView = chartView
            marker.minimumSize = CGSize(width: 40, height: 20)
            chartView.marker = marker
        } else if !shouldShowMarker && chartView.marker != nil {
            chartView.marker = nil
        }
    }
    
    func updateOtherChartData(yVals: [BarChartDataEntry]) { }
}

private extension AIChatChartCell {
    func updateChartData() {
        guard let models = chatModel?.barChartDatas, !models.isEmpty else {
            chartView.data = nil
            unitLabel.text = nil
            chartViewHeight.constant = defaultChartHeight
            return
        }
        
        unitLabel.text = "单位：" + "万" + (chatModel?.unitString ?? "")
        let names = models.map { $0.xAxis }
        chartView.xAxis.valueFormatter = NameValueFormatter(names: names)
        
        // 更新图表高度
        let font = chartView.xAxis.labelFont
        let longestName = longestDisplayedString(in: names, font: font)
        calcHeightLabel.font = font
        calcHeightLabel.text = longestName
        var height = rotatedLabelHeight(label: calcHeightLabel, rotationAngle: -75)
        height = max(defaultChartHeight, (height + defaultChartHeight - 41.74))
        if height != chartViewHeight.constant {
            chartViewHeight.constant = height
        }
        
        var entries = [BarChartDataEntry]()
        for (i, model) in models.enumerated() {
            let yValues = model.values.map { $0 / 10000.0 }
            let entry = BarChartDataEntry(x: Double(i), yValues: yValues)
            entries.append(entry)
        }
        
        var colors = [UIColor]()
        if let data = models.first {
            colors = data.colors
        }
        
        var labels = [String]()
        if let data = models.first {
            labels = data.labels
        }
        
        setChartData(yVals: entries, colors: colors, labels: labels)
    }
    
    func setChartData(yVals: [BarChartDataEntry], colors: [UIColor], labels: [String]) {
        let dataCount = yVals.count
        
        // 避免重复设置相同的值
        if chartView.xAxis.labelCount != min(dataCount, maxVisibleCount) {
            chartView.xAxis.labelCount = min(dataCount, maxVisibleCount)
        }
        
        let set1 = BarChartDataSet(entries: yVals)
        set1.colors = colors
        set1.stackLabels = labels
        set1.highlightColor = UIColor.blue.withAlphaComponent(0.1)
        set1.drawValuesEnabled = false
        set1.highlightLineWidth = 0.2
        set1.highlightLineDashPhase = 0.8
        
        let data = BarChartData(dataSet: set1)
        let barWidth = dynamicBarWidth(yVals.count)
        data.barWidth = traitCollection.horizontalSizeClass == .regular ? barWidth * 0.5 : barWidth
        
        chartView.data = data
        
        // 设置 marker
        updateChartMarker(yVals.first?.yValues?.count)
        // 设置其它图表相关数据
        updateOtherChartData(yVals: yVals)
    }
    
    func dynamicBarWidth(_ count: Int) -> Double {
        let base = 0.5
        guard count <= maxVisibleCount else {
            return base
        }
        let scale = Double(count) / Double(maxVisibleCount)
        return base * scale
    }
}

private extension AIChatChartCell {
    func longestDisplayedString(in array: [String], font: UIFont) -> String? {
        // 将每个字符串的显示宽度计算出来并存储
        let longestString = array.max { string1, string2 in
            let width1 = (string1 as NSString).size(withAttributes: [.font: font]).width
            let width2 = (string2 as NSString).size(withAttributes: [.font: font]).width
            return width1 < width2
        }
        return longestString
    }
    
    func rotatedLabelHeight(label: UILabel, rotationAngle: CGFloat) -> CGFloat {
        // 获取旋转前的 label 尺寸
        let originalSize = label.intrinsicContentSize
        
        // 创建一个原始的矩形
        let originalRect = CGRect(origin: .zero, size: originalSize)
        
        // 创建一个旋转变换，转换角度要转换为弧度
        let rotationTransform = CGAffineTransform(rotationAngle: rotationAngle * CGFloat.pi / 180)
        
        // 获取旋转后的矩形
        let rotatedRect = originalRect.applying(rotationTransform)
        
        // 返回旋转后的高度
        return rotatedRect.height
    }
}
