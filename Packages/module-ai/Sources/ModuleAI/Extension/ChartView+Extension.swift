//
//  ChartView+Extension.swift
//  ModuleAI
//
//  Created by Janlor on 2024/10/24.
//

import UIKit
import BaseUI
import DGCharts

extension ChartViewBase {
    func setupChart() {
        chartDescription.enabled = false
        legend.enabled = false
        noDataText = NSLocalizedString("暂无数据", bundle: .module, comment: "")
        noDataTextColor = .theme.tertieryLabel
    }
}

extension BarLineChartViewBase {
    func setupBarLineChart() {
        pinchZoomEnabled = false
        dragXEnabled = true
        dragYEnabled = false
        setScaleEnabled(false)
        rightAxis.enabled = false
        
        let xAxis = self.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = UIFont.systemFont(ofSize: 10)
        xAxis.drawAxisLineEnabled = false
        xAxis.drawGridLinesEnabled = false
        xAxis.labelTextColor = .theme.tertieryLabel
        xAxis.labelRotationAngle = -75.0
        xAxis.granularity = 1
        
        let leftAxis = self.leftAxis
        leftAxis.labelFont = .theme.caption1
        leftAxis.labelTextColor = .theme.tertieryLabel
        leftAxis.labelCount = 5
        leftAxis.drawAxisLineEnabled = false
        leftAxis.gridColor = .theme.separator
        leftAxis.gridLineWidth = 0.5
        leftAxis.labelPosition = .outsideChart
    }
}

extension BarChartView {
    func setupBarChart() {
        drawBarShadowEnabled = false
        drawValueAboveBarEnabled = false
    }
}
