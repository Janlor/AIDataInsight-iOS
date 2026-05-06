//
//  DefaultHistoryRepository.swift
//  ModuleAI
//
//  Created by Codex on 2026/1/1.
//

import Foundation
import CommonViewModel
import Networking

struct DefaultHistoryRepository: HistoryRepository {
    private let networkExecutor: NetworkExecutor

    init(networkExecutor: NetworkExecutor = NetworkExecutor()) {
        self.networkExecutor = networkExecutor
    }

    func loadHistoryPage(pageNo: Int, pageSize: Int) async throws -> RecordPageModel {
        let response = try await networkExecutor.request(HistoryApi.page(pageNo, pageSize), as: ResponseModel<RecordPageModel>.self)
        guard let data = response.data else {
            throw CommonRequesterError.emptyResponse
        }
        return data
    }
    
    func deleteHistory(historyId: Int) async throws {
        _ = try await networkExecutor.request(HistoryApi.delete(historyId), as: ResponseModel<AnyCodable>.self)
    }
    
    func deleteAllHistory() async throws {
        _ = try await networkExecutor.request(HistoryApi.deleteAll, as: ResponseModel<AnyCodable>.self)
    }
}
