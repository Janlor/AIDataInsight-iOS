//
//  AIChatLegendChartCell.swift
//  ModuleAI
//
//  Created by Janlor on 4/22/26.
//

import UIKit
import BaseUI
import DGCharts

class AIChatLegendChartCell: AIChatChartCell {
    private lazy var legendView: AIBarChartLegendView<AIBarChartLegend> = {
        let config = AIBarChartLegendView<AIBarChartLegend>.Configuration()
        let view = AIBarChartLegendView<AIBarChartLegend>(config: config)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.didChangeToHeight = { [weak self] height in
            guard let `self` = self else { return }
            guard self.legendViewHeight.constant != height else { return }
            self.legendViewHeight.constant = height
            self.updateCollectionView()
        }
        view.displayColorFor = { $0?.color }
        view.displayTitleFor = { $0?.title }
        return view
    }()
    private var legendViewHeight: NSLayoutConstraint!
    
    private lazy var legendDataView: AIBarChartLegendDataView<AIBarChartLegend> = {
        let view = AIBarChartLegendDataView<AIBarChartLegend>()
        view.backgroundColor = UIColor.theme.tertieryGroupedBackground
        view.applyCapsule(.small)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.didChangeToHeight = { [weak self] height in
            guard let `self` = self else { return }
            guard self.legendDataViewHeight.constant != height else { return }
            self.legendDataViewHeight.constant = height
            self.updateCollectionView()
        }
        view.displayColorFor = { $0?.color }
        view.displayTitleFor = { model in
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.theme.caption1,
                .foregroundColor: UIColor.theme.label
            ]
            let value = model?.title ?? ""
            return NSAttributedString(string: value, attributes: attributes)
        }
        view.displayValueFor = { [weak self] model in
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.theme.title4,
                .foregroundColor: UIColor.theme.label
            ]
            let value = model?.value ?? 0
            let valueStr = formattedScaleNumber(value)
            let unitString = self?.chatModel?.unitString ?? ""
            let string = valueStr.0 + valueStr.1 + unitString
            return NSAttributedString(string: string, attributes: attributes)
        }
        return view
    }()
    private var legendDataViewHeight: NSLayoutConstraint!
    
    override func setupViews() {
        super.setupViews()
        chartStackView.insertArrangedSubview(legendView, at: 0)
        chartStackView.addArrangedSubview(legendDataView)
        legendViewHeight = legendView.heightAnchor.constraint(equalToConstant: 0)
        legendDataViewHeight = legendDataView.heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            legendViewHeight,
            legendDataViewHeight
        ])
    }
    
    override func updateChartMarker(_ count: Int?) {
        // 啥都不做 堆叠不需要 marker
    }
    
    override func updateOtherChartData(yVals: [BarChartDataEntry]) {
        guard chartView.marker == nil else {
            return
        }
        
        displayLegendView(entry: yVals.last)
        
        // 默认选中最后一个
        DispatchQueue.main.async {
            if let dataEntries = self.chartView.data?.dataSets.first?.entryCount {
                let lastIndex = dataEntries - 1
                self.chartView.highlightValue(x: Double(lastIndex), dataSetIndex: 0)
            }
        }
        
        chartView.delegate = self
        displayLegendDataView(entry: yVals.last)
    }
}

private extension AIChatLegendChartCell {
    func displayLegendView(entry: ChartDataEntry?) {
        guard let entry = entry,
              let models = chatModel?.barChartDatas,
              let first = models.first,
              first.values.count > 1 else {
            legendView.isHidden = true
            legendView.dataSource = [AIBarChartLegend]()
            return
        }
        
        legendView.isHidden = false
        let model = models[Int(entry.x)]
        var legends = [AIBarChartLegend]()
        let count = min(model.labels.count, model.colors.count)
        for i in 0..<count {
            let legend = AIBarChartLegend(color: model.colors[i], title: model.labels[i], value: model.values[i])
            legends.append(legend)
        }
        legendView.dataSource = legends
    }
    
    func displayLegendDataView(entry: ChartDataEntry?) {
        guard let entry = entry,
              let models = chatModel?.barChartDatas,
              let first = models.first,
              first.values.count > 1 else {
            legendDataView.isHidden = true
            legendDataView.dataSource = [AIBarChartLegend]()
            return
        }
        
        legendDataView.isHidden = false
        let model = models[Int(entry.x)]
        var legends = [AIBarChartLegend]()
        let count = min(model.labels.count, model.colors.count)
        for i in 0..<count {
            let legend = AIBarChartLegend(color: model.colors[i], title: model.labels[i], value: model.values[i])
            legends.append(legend)
        }
        legendDataView.titleLabel.text = model.xAxis
        legendDataView.dataSource = legends
    }
}

extension AIChatLegendChartCell: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        displayLegendDataView(entry: entry)
        NSLog("chartValueSelected\(entry.description)");
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        displayLegendDataView(entry: nil)
        NSLog("chartValueNothingSelected");
    }
    
    func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {
        
    }
    
    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
        
    }
}
