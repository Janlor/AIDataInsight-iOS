//
//  AIBarChartData.swift
//  ModuleAI
//
//  Created by Janlor on 2024/10/24.
//

import UIKit
import BaseUI

struct AIBarChartData: Hashable {
    /// 横坐标
    let xAxis: String
    
    /// 颜色
    var colors: [UIColor]
    
    /// 标题
    var labels: [String]
    
    /// 值
    var values: [Double]
    
    /// 唯一标识
    private let identifier = UUID()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

extension AIBarChartData {
    
    /// AI 数据分析风格图表色板
    static let colorOptions: [UIColor] = [
        
        // MARK: - Primary Blue
        
        UIColor(alphaHex: 0xFF2F7BFF),
        UIColor(alphaHex: 0xCC2F7BFF),
        UIColor(alphaHex: 0x992F7BFF),
        
        // MARK: - Cyan
        
        UIColor(alphaHex: 0xFF18B8FF),
        UIColor(alphaHex: 0xCC18B8FF),
        UIColor(alphaHex: 0x9918B8FF),
        
        // MARK: - Mint
        
        UIColor(alphaHex: 0xFF33E0C4),
        UIColor(alphaHex: 0xCC33E0C4),
        UIColor(alphaHex: 0x9933E0C4),
        
        // MARK: - Green
        
        UIColor(alphaHex: 0xFF3DDC97),
        UIColor(alphaHex: 0xCC3DDC97),
        UIColor(alphaHex: 0x993DDC97),
        
        // MARK: - Purple
        
        UIColor(alphaHex: 0xFF8B7CFF),
        UIColor(alphaHex: 0xCC8B7CFF),
        UIColor(alphaHex: 0x998B7CFF),
        
        // MARK: - Orange
        
        UIColor(alphaHex: 0xFFFFB547),
        UIColor(alphaHex: 0xCCFFB547),
        UIColor(alphaHex: 0x99FFB547),
        
        // MARK: - Coral
        
        UIColor(alphaHex: 0xFFFF6B6B),
        UIColor(alphaHex: 0xCCFF6B6B),
        UIColor(alphaHex: 0x99FF6B6B)
    ]
}
