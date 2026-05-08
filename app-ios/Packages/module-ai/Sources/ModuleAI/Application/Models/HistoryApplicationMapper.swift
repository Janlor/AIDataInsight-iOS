//
//  HistoryApplicationMapper.swift
//  ModuleAI
//
//  Created by Codex on 2026/05/08.
//

import Foundation

enum HistoryApplicationMapper {
    static func groupRecords(
        _ records: [RecordModel]?,
        dateFormatter: DateFormatter
    ) -> [HistoryRecordGroup] {
        guard let records else { return [] }
        
        var groups: [HistoryRecordGroup] = []
        var currentRecords: [RecordModel] = []
        var currentKind: HistorySectionKind?
        
        for record in records {
            guard let date = dateFormatter.date(from: record.updateTime ?? "") else { continue }
            let kind = sectionKind(for: date, calendar: .current)
            
            if kind != currentKind {
                if let currentKind, !currentRecords.isEmpty {
                    groups.append(HistoryRecordGroup(kind: currentKind, records: currentRecords))
                }
                currentKind = kind
                currentRecords = [record]
            } else {
                currentRecords.append(record)
            }
        }
        
        if let currentKind, !currentRecords.isEmpty {
            groups.append(HistoryRecordGroup(kind: currentKind, records: currentRecords))
        }
        
        return groups
    }
    
    static func mergeGroups(
        existing: inout [HistoryRecordGroup],
        new: [HistoryRecordGroup]
    ) {
        for newGroup in new {
            if let existingIndex = existing.lastIndex(where: { $0.kind == newGroup.kind }) {
                existing[existingIndex].records.append(contentsOf: newGroup.records)
            } else {
                existing.append(newGroup)
            }
        }
    }
}

private extension HistoryApplicationMapper {
    static func sectionKind(for date: Date, calendar: Calendar) -> HistorySectionKind {
        if calendar.isDateInToday(date) {
            return .today
        } else if calendar.isDate(date, equalTo: Date(), toGranularity: .month) {
            return .thisMonth
        } else {
            return .other
        }
    }
}

