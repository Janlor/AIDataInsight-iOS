//
//  HistoryViewModel.swift
//  ModuleAI
//
//  Created by Janlor on 4/29/26.
//

import Foundation
import BaseKit
import CommonViewModel

final class HistoryViewModel: BaseViewModel {
    
    // MARK: - Output
    
    var onDataLoaded: (([[RecordModel]]) -> Void)?
    var onDataLoadFailed: ((String?) -> Void)?
    
    // MARK: - State
    
    let pageSize: Int = 50
    
    private(set) var pageModel: RecordPageModel?
    private(set) var dataSourse: [[RecordModel]] = []
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
}

extension HistoryViewModel {
    
    func reloadData() {
        getNewData()
    }
    
    func getNewData() {
        getDataList(pageNo: 1, pageSize: pageSize)
    }
    
    func getMoreData() {
        let current = (pageModel?.currentPage ?? 0) + 1
        getDataList(pageNo: current, pageSize: pageSize)
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
    
    func deleteHistory(at indexPath: IndexPath, completion: @escaping (Bool, Int?) -> Void) {
        let history = record(at: indexPath)
        guard let historyId = history.id else {
            completion(false, nil)
            return
        }
        
        let target = HistoryApi.delete(historyId)
        CommonRequester.requestVoid(target) { [weak self] success, _ in
            guard let self else { return }
            
            guard success else {
                completion(false, historyId)
                return
            }
            
            self.dataSourse[indexPath.section].remove(at: indexPath.row)
            if self.dataSourse[indexPath.section].isEmpty {
                self.dataSourse.remove(at: indexPath.section)
            }
            
            completion(true, historyId)
        }
    }
    
    func deleteAllHistory(completion: @escaping (Bool) -> Void) {
        let target = HistoryApi.deleteAll
        CommonRequester.requestVoid(target) { [weak self] success, _ in
            guard let self else { return }
            
            if success {
                self.dataSourse = []
                self.pageModel = nil
            }
            completion(success)
        }
    }
}

private extension HistoryViewModel {
    
    func getDataList(pageNo: Int, pageSize: Int) {
        let target = HistoryApi.page(pageNo, pageSize)
        
        CommonRequester.requestNet(target) { [weak self] (model: RecordPageModel?, error) in
            guard let self else { return }
            
            guard error == nil,
                  let model else {
                self.onDataLoadFailed?(error?.localizedDescription)
                return
            }
            
            self.pageModel = model
            
            DispatchQueue.global().async {
                let groupedNewRecords = RecordModel.groupRecordsByDate(
                    records: model.records,
                    dateFormatter: self.dateFormatter
                )
                
                if model.currentPage ?? 1 == 1 || self.dataSourse.isEmpty {
                    self.dataSourse = groupedNewRecords
                } else {
                    RecordModel.mergeGroupedRecords(
                        existing: &self.dataSourse,
                        new: groupedNewRecords,
                        dateFormatter: self.dateFormatter
                    )
                }
                
                let dataSourse = self.dataSourse
                DispatchQueue.main.async {
                    self.onDataLoaded?(dataSourse)
                }
            }
        }
    }
}
