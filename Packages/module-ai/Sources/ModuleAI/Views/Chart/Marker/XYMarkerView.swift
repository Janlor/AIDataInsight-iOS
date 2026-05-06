//
//  XYMarkerView.swift
//  ChartsDemo
//  Copyright © 2016 dcg. All rights reserved.
//

import Foundation
import BaseUI
#if canImport(UIKit)
    import UIKit
#endif
import DGCharts

open class XYMarkerView: BalloonMarker
{
    @objc open var xAxisValueFormatter: AxisValueFormatter?
    open var unit: String?
    
    @objc public init(color: UIColor, font: UIFont, textColor: UIColor, insets: UIEdgeInsets,
                      xAxisValueFormatter: AxisValueFormatter, unit: String?) {
        super.init(color: color, font: font, textColor: textColor, insets: insets)
        self.xAxisValueFormatter = xAxisValueFormatter
        self.arrowSize = CGSize(width: 8, height: -2)
        self.unit = unit
    }
    
    open override func refreshContent(entry: ChartDataEntry, highlight: Highlight)
    {
        var xValue = xAxisValueFormatter!.stringForValue(entry.x, axis: nil)
        let y = entry.y * 10000.0
        let yValue = formattedScaleNumber(y)
        xValue += ("\n" + yValue.0 + yValue.1)
        if let unit = unit {
            xValue += unit
        }
        setLabel(xValue)
    }
    
}
