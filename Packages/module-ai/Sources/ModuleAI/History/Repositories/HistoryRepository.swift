//
//  HistoryRepository.swift
//  ModuleAI
//
//  Created by Codex on 2026/1/1.
//

import Foundation
import CommonViewModel

protocol HistoryRepository {
    func loadHistoryPage(pageNo: Int, pageSize: Int) async throws -> RecordPageModel
    func deleteHistory(historyId: Int) async throws
    func deleteAllHistory() async throws
}

struct DefaultHistoryRepository: HistoryRepository {
    func loadHistoryPage(pageNo: Int, pageSize: Int) async throws -> RecordPageModel {
        try await CommonRequester.requestNet(HistoryApi.page(pageNo, pageSize))
    }
    
    func deleteHistory(historyId: Int) async throws {
        try await CommonRequester.requestVoid(HistoryApi.delete(historyId))
    }
    
    func deleteAllHistory() async throws {
        try await CommonRequester.requestVoid(HistoryApi.deleteAll)
    }
}
