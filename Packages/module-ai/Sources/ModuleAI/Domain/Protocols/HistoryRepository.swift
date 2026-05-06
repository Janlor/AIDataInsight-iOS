//
//  HistoryRepository.swift
//  ModuleAI
//
//  Created by Codex on 2026/1/1.
//

import Foundation

protocol HistoryRepository {
    func loadHistoryPage(pageNo: Int, pageSize: Int) async throws -> RecordPageModel
    func deleteHistory(historyId: Int) async throws
    func deleteAllHistory() async throws
}
