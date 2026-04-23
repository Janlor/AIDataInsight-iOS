//
//  AIBarChartRenderer.swift
//  ModuleAI
//
//  Created by Janlor on 4/22/26.
//

import Foundation
import CoreGraphics
import DGCharts

class AIBarChartRenderer: BarChartRenderer {
    open func prepareBarHighlight(
        x: Double,
        y1: Double,
        y2: Double,
        barWidthHalf: Double,
        trans: Transformer,
        rect: inout CGRect,
        mRect: inout CGRect)
    {
        let left = x - barWidthHalf
        let right = x + barWidthHalf
        let top = dataProvider?.chartYMax ?? 0
        let bottom = y2
        
        rect.origin.x = CGFloat(left)
        rect.origin.y = CGFloat(top)
        rect.size.width = CGFloat(right - left)
        rect.size.height = CGFloat(bottom - top)
        
        mRect.origin.x = CGFloat(left)
        mRect.origin.y = CGFloat(y1)
        mRect.size.width = CGFloat(right - left)
        mRect.size.height = CGFloat(bottom - top)
        
        trans.rectValueToPixel(&rect, phaseY: animator.phaseY )
        trans.rectValueToPixel(&mRect, phaseY: animator.phaseY )
    }
    
    override func drawHighlighted(context: CGContext, indices: [Highlight])
    {
        guard
            let dataProvider = dataProvider,
            let barData = dataProvider.barData
        else { return }
        
        context.saveGState()
        defer { context.restoreGState() }
        var barRect = CGRect()
        var marRect = CGRect()
        
        for high in indices
        {
            guard
                let set = barData[high.dataSetIndex] as? BarChartDataSetProtocol,
                set.isHighlightEnabled
            else { continue }
            
            if let e = set.entryForXValue(high.x, closestToY: high.y) as? BarChartDataEntry
            {
                guard isInBoundsX(entry: e, dataSet: set) else { continue }
                
                let trans = dataProvider.getTransformer(forAxis: set.axisDependency)
                
                context.setFillColor(set.highlightColor.cgColor)
                context.setAlpha(set.highlightAlpha)
                
                let isStack = high.stackIndex >= 0 && e.isStacked
                
                let y1: Double
                let y2: Double
                
                if isStack
                {
                    if dataProvider.isHighlightFullBarEnabled
                    {
                        y1 = e.positiveSum
                        y2 = -e.negativeSum
                    }
                    else
                    {
                        let range = e.ranges?[high.stackIndex]
                        
                        y1 = range?.from ?? 0.0
                        y2 = range?.to ?? 0.0
                    }
                }
                else
                {
                    y1 = e.y
                    y2 = 0.0
                }
                
                prepareBarHighlight(x: e.x, y1: y1, y2: y2, barWidthHalf: barData.barWidth, trans: trans, rect: &barRect, mRect: &marRect)
                
                setHighlightDrawPos(highlight: high, barRect: marRect)
                
                context.fill(barRect)
            }
        }
    }
    
    /// Checks if the provided entry object is in bounds for drawing considering the current animation phase.
    internal func isInBoundsX(entry e: ChartDataEntry, dataSet: BarLineScatterCandleBubbleChartDataSetProtocol) -> Bool
    {
        let entryIndex = dataSet.entryIndex(entry: e)
        return Double(entryIndex) < Double(dataSet.entryCount) * animator.phaseX
    }
    
    /// Sets the drawing position of the highlight object based on the given bar-rect.
    internal func setHighlightDrawPos(highlight high: Highlight, barRect: CGRect)
    {
        high.setDraw(x: barRect.midX, y: barRect.origin.y)
    }
}
