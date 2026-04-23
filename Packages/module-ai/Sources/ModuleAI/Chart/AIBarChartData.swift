//
//  AIBarChartData.swift
//  ModuleAI
//
//  Created by Janlor on 4/22/26.
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

    /// 图表颜色
    static let colorOptions: [UIColor] = [
        UIColor(alphaHex: 0xFFFF9903),
        UIColor(alphaHex: 0xFFF6501D),
        UIColor(alphaHex: 0xFF840AFD),
        UIColor(alphaHex: 0xFFA0DD6A),
        UIColor(alphaHex: 0xFF01A6ED),
        UIColor(alphaHex: 0xFF1FB9B7),
        UIColor(alphaHex: 0xFF2B578D),
        UIColor(alphaHex: 0xAAFFC009),
        UIColor(alphaHex: 0xAAF6501D),
        UIColor(alphaHex: 0xAA840AFD),
        UIColor(alphaHex: 0xAAA0DD6A),
        UIColor(alphaHex: 0xAA01A6ED),
        UIColor(alphaHex: 0xAA1FB9B7),
        UIColor(alphaHex: 0xAA2B578D),
        UIColor(alphaHex: 0x66FFC009),
        UIColor(alphaHex: 0x66F6501D),
        UIColor(alphaHex: 0x66840AFD),
        UIColor(alphaHex: 0x66A0DD6A),
        UIColor(alphaHex: 0x6601A6ED),
        UIColor(alphaHex: 0x661FB9B7),
        UIColor(alphaHex: 0x662B578D),
        UIColor(alphaHex: 0x99FFC009),
        UIColor(alphaHex: 0x99F6501D),
        UIColor(alphaHex: 0x99840AFD),
        UIColor(alphaHex: 0x99A0DD6A),
        UIColor(alphaHex: 0x9901A6ED),
        UIColor(alphaHex: 0x991FB9B7),
        UIColor(alphaHex: 0x992B578D)
    ]
}
