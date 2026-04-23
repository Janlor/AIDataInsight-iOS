//
//  NameValueFormatter.swift
//  ModuleAI
//
//  Created by Janlor on 4/22/26.
//

import UIKit
import DGCharts

public class NameValueFormatter: NSObject, AxisValueFormatter {
    var names: [String]?
    
    init(names: [String]?) {
        self.names = names
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        guard let names = names else { return "" }
        let index = Int(value) // 0,1,2
        guard index < names.count else { return "" }
        let str = names[index] // "01", "12"
        return str
    }
}
