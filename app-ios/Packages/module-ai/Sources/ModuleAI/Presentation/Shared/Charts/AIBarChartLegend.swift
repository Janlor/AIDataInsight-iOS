//
//  AIBarChartLegend.swift
//  ModuleAI
//
//  Created by Janlor on 2024/10/24.
//

import UIKit

struct AIBarChartLegend: Hashable {
    /// 颜色
    var color: UIColor
    /// 标题
    var title: String
    /// 值
    var value: Double
    /// 唯一标识
    private let identifier = UUID()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
