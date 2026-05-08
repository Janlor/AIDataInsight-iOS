//
//  LoadHistoryPageUseCase.swift
//  ModuleAI
//
//  Created by Codex on 2026/1/8.
//

import Foundation

struct LoadHistoryPageUseCase {
    private let repository: HistoryRepository
    private let dateFormatter: DateFormatter

    init(repository: HistoryRepository, dateFormatter: DateFormatter) {
        self.repository = repository
        self.dateFormatter = dateFormatter
    }

    func execute(
        pageNo: Int,
        pageSize: Int,
        existingGroups: [HistoryRecordGroup]
    ) async throws -> HistoryStateSnapshot {
        let pageModel = try await repository.loadHistoryPage(pageNo: pageNo, pageSize: pageSize)
        let groupedNewRecords = HistoryApplicationMapper.groupRecords(
            pageModel.records,
            dateFormatter: dateFormatter
        )

        let mergedGroups: [HistoryRecordGroup]
        if (pageModel.currentPage ?? 1) == 1 || existingGroups.isEmpty {
            mergedGroups = groupedNewRecords
        } else {
            var merged = existingGroups
            HistoryApplicationMapper.mergeGroups(existing: &merged, new: groupedNewRecords)
            mergedGroups = merged
        }

        return HistoryStateSnapshot(
            pageModel: pageModel,
            recordGroups: mergedGroups
        )
    }
}
