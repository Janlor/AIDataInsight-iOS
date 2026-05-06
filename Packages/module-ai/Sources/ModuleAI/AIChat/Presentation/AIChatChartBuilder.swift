//
//  AIChatChartBuilder.swift
//  ModuleAI
//
//  Created by Codex on 2026/1/1.
//

import Foundation

enum AIChatChartBuilder {
    static func build(from model: HistoryDetailModel) -> ([AIBarChartData]?, String?) {
        if let list = model.chartCommonVoList, !list.isEmpty {
            let datas = list.map { item in
                let title = item.name ?? ""
                let value = item.value ?? 0
                let color = AIBarChartData.colorOptions.first ?? .systemBlue
                
                return AIBarChartData(
                    xAxis: title,
                    colors: [color],
                    labels: [title],
                    values: [value]
                )
            }
            return (datas, nil)
        }
        
        if let list = model.accountAgeGroupVoList, !list.isEmpty {
            if let first = list.first,
               first.chartType == "2",
               let msg = first.msg {
                return (nil, msg)
            }
            
            let datas = list.map { item in
                let name = item.name ?? ""
                let values = item.valueList ?? []
                let labels = item.labelList ?? []
                
                let colors = values.indices.map {
                    AIBarChartData.colorOptions[$0 % AIBarChartData.colorOptions.count]
                }
                
                return AIBarChartData(
                    xAxis: name,
                    colors: colors,
                    labels: labels,
                    values: values
                )
            }
            
            return (datas, nil)
        }
        
        return (nil, nil)
    }
}
