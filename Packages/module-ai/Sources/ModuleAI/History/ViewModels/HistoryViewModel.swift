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
    
    var onDataLoaded: (([[RecordModel]]) -> Void)?
    var onDataLoadFailed: ((String?) -> Void)?
    
    // MARK: - State
    
    let pageSize: Int = 50
    
    private(set) var pageModel: RecordPageModel?
    private(set) var dataSourse: [[RecordModel]] = []
    
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
        dataSourse.count
    }
    
    func numberOfRows(in section: Int) -> Int {
        dataSourse[section].count
    }
    
    func record(at indexPath: IndexPath) -> RecordModel {
        dataSourse[indexPath.section][indexPath.row]
    }
    
    func titleForHeader(in section: Int) -> String? {
        guard let firstRecord = dataSourse[section].first,
              let date = dateFormatter.date(from: firstRecord.updateTime ?? "")
        else { return nil }
        
        return RecordModel.groupKeyForDate(date, calendar: .current).0
    }
}

extension HistoryViewModel {
    
    func deleteHistory(at indexPath: IndexPath) async throws -> Int {
        let history = record(at: indexPath)
        guard let historyId = history.id else {
            throw CommonRequesterError.requestFailed
        }
        
        try await repository.deleteHistory(historyId: historyId)
        
        dataSourse[indexPath.section].remove(at: indexPath.row)
        if dataSourse[indexPath.section].isEmpty {
            dataSourse.remove(at: indexPath.section)
        }
        
        return historyId
    }
    
    func deleteAllHistory() async throws {
        try await repository.deleteAllHistory()
        dataSourse = []
        pageModel = nil
    }
}

private extension HistoryViewModel {
    
    func getDataList(pageNo: Int, pageSize: Int) async {
        do {
            let model = try await repository.loadHistoryPage(pageNo: pageNo, pageSize: pageSize)
            pageModel = model
            
            let groupedNewRecords = RecordModel.groupRecordsByDate(
                records: model.records,
                dateFormatter: dateFormatter
            )
            
            let mergedDataSource: [[RecordModel]]
            if (model.currentPage ?? 1) == 1 || dataSourse.isEmpty {
                mergedDataSource = groupedNewRecords
            } else {
                var merged = dataSourse
                RecordModel.mergeGroupedRecords(
                    existing: &merged,
                    new: groupedNewRecords,
                    dateFormatter: dateFormatter
                )
                mergedDataSource = merged
            }
            
            dataSourse = mergedDataSource
            onDataLoaded?(mergedDataSource)
        } catch {
            onDataLoadFailed?(error.localizedDescription)
        }
    }
}
