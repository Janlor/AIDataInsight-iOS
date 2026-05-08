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
    private let loadHistoryPageUseCase: LoadHistoryPageUseCase
    private let deleteHistoryUseCase: DeleteHistoryUseCase
    private let deleteAllHistoryUseCase: DeleteAllHistoryUseCase
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    init(repository: HistoryRepository = DefaultHistoryRepository()) {
        self.repository = repository
        self.loadHistoryPageUseCase = LoadHistoryPageUseCase(
            repository: repository,
            dateFormatter: Self.makeDateFormatter()
        )
        self.deleteHistoryUseCase = DeleteHistoryUseCase(repository: repository)
        self.deleteAllHistoryUseCase = DeleteAllHistoryUseCase(repository: repository)
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
        let output = try await deleteHistoryUseCase.execute(
            recordGroups: recordGroups,
            indexPath: indexPath
        )
        recordGroups = output.state.recordGroups
        sections = output.state.sections
        return output.historyId
    }
    
    func deleteAllHistory() async throws {
        let state = try await deleteAllHistoryUseCase.execute()
        recordGroups = state.recordGroups
        sections = state.sections
        pageModel = state.pageModel
    }
}

private extension HistoryViewModel {
    
    func getDataList(pageNo: Int, pageSize: Int) async {
        do {
            let state = try await loadHistoryPageUseCase.execute(
                pageNo: pageNo,
                pageSize: pageSize,
                existingGroups: recordGroups
            )
            pageModel = state.pageModel
            recordGroups = state.recordGroups
            sections = state.sections
            onDataLoaded?(sections)
        } catch {
            onDataLoadFailed?(error.localizedDescription)
        }
    }
}

private extension HistoryViewModel {
    static func makeDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }
}
