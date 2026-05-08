//
//  HistoryListViewData.swift
//  ModuleAI
//
//  Created by Codex on 2026/1/1.
//

import Foundation
import UIKit
import BaseUI

struct HistoryListItemViewData {
    let id: Int?
    let titleText: NSAttributedString
}

struct HistorySectionViewData {
    let title: String
    let items: [HistoryListItemViewData]
}

enum HistoryListViewDataBuilder {
    static func makeSections(from groups: [HistoryRecordGroup]) -> [HistorySectionViewData] {
        groups.map { group in
            HistorySectionViewData(
                title: localizedTitle(for: group.kind),
                items: group.records.map { makeItemViewData(from: $0, kind: group.kind) }
            )
        }
    }
    
    static func makeItemViewData(from record: RecordModel, kind: HistorySectionKind) -> HistoryListItemViewData {
        let displayTime = localTime(dateTime: record.updateTime, for: kind)
        let title = (record.name ?? "") + " "
        let titleText = AIChatRichText(text: title, attributes: [
            .foregroundColor: UIColor.theme.secondaryLabel,
            .font: UIFont.theme.subhead
        ])
        let dateText = AIChatRichText(text: displayTime, attributes: [
            .foregroundColor: UIColor.theme.tertiaryLabel,
            .font: UIFont.theme.caption1
        ])
        
        return HistoryListItemViewData(
            id: record.id,
            titleText: AIChatRichText.attributedString(from: [titleText, dateText])
        )
    }
    
    private static func localizedTitle(for kind: HistorySectionKind) -> String {
        switch kind {
        case .today:
            return NSLocalizedString("今天", bundle: .module, comment: "")
        case .thisMonth:
            return NSLocalizedString("本月", bundle: .module, comment: "")
        case .other:
            return NSLocalizedString("其它", bundle: .module, comment: "")
        }
    }
    
    private static func localTime(dateTime: String?, for kind: HistorySectionKind) -> String {
        let range: ClosedRange<Int>
        switch kind {
        case .today:
            range = 11...15
        case .thisMonth:
            range = 5...9
        case .other:
            range = 0...9
        }
        
        guard let dateString = dateTime, dateString.count > range.upperBound else { return "" }
        let startIndex = dateString.index(dateString.startIndex, offsetBy: range.lowerBound)
        let endIndex = dateString.index(dateString.startIndex, offsetBy: range.upperBound)
        return String(dateString[startIndex...endIndex])
    }
}
