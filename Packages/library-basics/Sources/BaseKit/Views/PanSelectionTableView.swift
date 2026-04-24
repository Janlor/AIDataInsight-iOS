//
//  PanSelectionTableView.swift
//  LibraryBasics
//
//  Created by Janlor on 5/31/24.
//

import UIKit
import AudioToolbox.AudioServices

public class PanSelectionTableView: UITableView {

    // MARK: - Properties
    
    public var disablePanGesture: Bool = false {
        didSet {
            panGesture.isEnabled = !disablePanGesture
        }
    }

    private lazy var feedbackGenerator: UISelectionFeedbackGenerator = {
        let feedback = UISelectionFeedbackGenerator()
        feedback.prepare()
        return feedback
    }()
    private var highlightedCell: UITableViewCell?
    private var panGesture: UIPanGestureRecognizer!

    // MARK: - Initializers

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        addPanGesture()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addPanGesture()
    }

    // MARK: - Gesture

    private func addPanGesture() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(panAction(_:)))
        addGestureRecognizer(panGesture)
    }

    // MARK: - Actions

    @objc private func panAction(_ pan: UIPanGestureRecognizer) {
        if pan.state == .began || pan.state == .changed {
            highlightedCell?.isHighlighted = false
            let location = pan.location(in: self)
            var findCell: UITableViewCell?
            for cell in visibleCells {
                let cellPoint = cell.convert(location, from: self)
                if cell.point(inside: cellPoint, with: nil) {
                    cell.isHighlighted = true
                    findCell = cell
                    break
                }
            }
            setupHighlightedCell(findCell)
            return
        }

        if pan.state == .ended || pan.state == .cancelled {
            for cell in visibleCells where cell.isHighlighted {
                if let indexPath = indexPath(for: cell) {
                    delegate?.tableView?(self, didSelectRowAt: indexPath)
                }
                cell.isHighlighted = false
                break
            }
        }
    }

    private func selectionChanged() {
        // 播放声音
        AudioServicesPlaySystemSound(1104) // 1104 对应于 `Tock.aiff`
        feedbackGenerator.selectionChanged()
        feedbackGenerator.prepare()
    }

    // MARK: - Setters

    private func setupHighlightedCell(_ cell: UITableViewCell?) {
        let isEqual = highlightedCell == cell
        
        if highlightedCell != nil && cell != nil && !isEqual {
            selectionChanged()
        }
        
        if !isEqual && highlightedCell != nil {
            highlightedCell?.isHighlighted = false
        }
        
        if let highlighted = cell {
            highlightedCell = highlighted
        }
    }
}
