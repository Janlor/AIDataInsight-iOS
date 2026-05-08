//
//  LoadChartDataUseCase.swift
//  ModuleAI
//
//  Created by Codex on 2026/1/8.
//

import Foundation

struct LoadChartDataUseCase {
    private let repository: AIChatRepository

    init(repository: AIChatRepository) {
        self.repository = repository
    }

    func execute(
        name: FunctionName,
        historyId: Int,
        arguments: FunctionArguments
    ) async throws -> UseCaseResult<LoadChartDataOutput> {
        guard name.argumentKind == arguments.argumentKind else {
            return .failure(.message("函数参数类型不匹配。"))
        }
        
        let model = try await repository.loadChartData(
            name: name,
            historyId: historyId,
            arguments: arguments
        )
        let payload = AIChatApplicationMapper.makeChartPayload(from: model)
        guard let payload, payload.series.isEmpty == false else {
            return .failure(.message(
                payload?.emptyMessage
                ?? "数据分析还在测试阶段，很快就能上线，敬请期待！"
            ))
        }

        return .success(LoadChartDataOutput(payload: payload))
    }
}
