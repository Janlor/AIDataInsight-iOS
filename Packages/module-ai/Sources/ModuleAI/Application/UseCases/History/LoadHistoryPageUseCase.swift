//
//  LoadHistoryPageUseCase.swift
//  ModuleAI
//
//  Created by Codex on 2026/1/8.
//

import Foundation

struct LoadHistoryPageUseCaseResult {
    let pageModel: RecordPageModel
    let recordGroups: [HistoryRecordGroup]
    let sections: [HistorySectionViewData]
}

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
    ) async throws -> LoadHistoryPageUseCaseResult {
        let pageModel = try await repository.loadHistoryPage(pageNo: pageNo, pageSize: pageSize)
        let groupedNewRecords = HistoryListViewDataBuilder.groupRecords(
            pageModel.records,
            dateFormatter: dateFormatter
        )

        let mergedGroups: [HistoryRecordGroup]
        if (pageModel.currentPage ?? 1) == 1 || existingGroups.isEmpty {
            mergedGroups = groupedNewRecords
        } else {
            var merged = existingGroups
            HistoryListViewDataBuilder.mergeGroups(existing: &merged, new: groupedNewRecords)
            mergedGroups = merged
        }

        return LoadHistoryPageUseCaseResult(
            pageModel: pageModel,
            recordGroups: mergedGroups,
            sections: HistoryListViewDataBuilder.makeSections(from: mergedGroups)
        )
    }
}
