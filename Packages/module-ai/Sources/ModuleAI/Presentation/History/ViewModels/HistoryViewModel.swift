//
//  HistoryViewModel.swift
//  ModuleAI
//
//  Created by Janlor on 4/29/26.
//

import Foundation
import BaseKit
import CommonViewModel

@MainActor
final class HistoryViewModel: BaseViewModel {
    
    // MARK: - Output
    
    var onDataLoaded: (([HistorySectionViewData]) -> Void)?
    var onDataLoadFailed: ((String?) -> Void)?
    
    // MARK: - State
    
    let pageSize: Int = 50
    
    private(set) var pageModel: RecordPageModel?
    private(set) var recordGroups: [HistoryRecordGroup] = []
    private(set) var sections: [HistorySectionViewData] = []
    
    private let repository: HistoryRepository
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    init(repository: HistoryRepository = DefaultHistoryRepository()) {
        self.repository = repository
        super.init()
    }
}

extension HistoryViewModel {
    
    func reloadData() async {
        await getNewData()
    }
    
    func getNewData() async {
        await getDataList(pageNo: 1, pageSize: pageSize)
    }
    
    func getMoreData() async {
        let current = (pageModel?.currentPage ?? 0) + 1
        await getDataList(pageNo: current, pageSize: pageSize)
    }
    
    func numberOfSections() -> Int {
        sections.count
    }
    
    func numberOfRows(in section: Int) -> Int {
        sections[section].items.count
    }
    
    func record(at indexPath: IndexPath) -> RecordModel {
        recordGroups[indexPath.section].records[indexPath.row]
    }
    
    func item(at indexPath: IndexPath) -> HistoryListItemViewData {
        sections[indexPath.section].items[indexPath.row]
    }
    
    func titleForHeader(in section: Int) -> String? {
        sections[section].title
    }
}

extension HistoryViewModel {
    
    func deleteHistory(at indexPath: IndexPath) async throws -> Int {
        let history = record(at: indexPath)
        guard let historyId = history.id else {
            throw CommonRequesterError.requestFailed
        }
        
        try await repository.deleteHistory(historyId: historyId)
        
        recordGroups[indexPath.section].records.remove(at: indexPath.row)
        if recordGroups[indexPath.section].records.isEmpty {
            recordGroups.remove(at: indexPath.section)
        }
        sections = HistoryListViewDataBuilder.makeSections(from: recordGroups)
        
        return historyId
    }
    
    func deleteAllHistory() async throws {
        try await repository.deleteAllHistory()
        recordGroups = []
        sections = []
        pageModel = nil
    }
}

private extension HistoryViewModel {
    
    func getDataList(pageNo: Int, pageSize: Int) async {
        do {
            let model = try await repository.loadHistoryPage(pageNo: pageNo, pageSize: pageSize)
            pageModel = model
            
            let groupedNewRecords = HistoryListViewDataBuilder.groupRecords(
                model.records,
                dateFormatter: dateFormatter
            )
            
            let mergedGroups: [HistoryRecordGroup]
            if (model.currentPage ?? 1) == 1 || recordGroups.isEmpty {
                mergedGroups = groupedNewRecords
            } else {
                var merged = recordGroups
                HistoryListViewDataBuilder.mergeGroups(existing: &merged, new: groupedNewRecords)
                mergedGroups = merged
            }
            
            recordGroups = mergedGroups
            sections = HistoryListViewDataBuilder.makeSections(from: mergedGroups)
            onDataLoaded?(sections)
        } catch {
            onDataLoadFailed?(error.localizedDescription)
        }
    }
}
