//
//  AIChatChartBuilder.swift
//  ModuleAI
//
//  Created by Codex on 2026/1/1.
//

import Foundation
import UIKit

enum AIChatChartBuilder {
    static func build(from payload: ChartPayload) -> [AIBarChartData] {
        payload.series.map { series in
            let colors = series.values.indices.map {
                AIBarChartData.colorOptions[$0 % AIBarChartData.colorOptions.count]
            }
            
            return AIBarChartData(
                xAxis: series.xAxis,
                colors: colors.isEmpty ? [.systemBlue] : colors,
                labels: series.labels,
                values: series.values
            )
        }
    }
}
