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
        let model = try await repository.loadChartData(
            name: name,
            historyId: historyId,
            arguments: arguments
        )
        let result = AIChatChartBuilder.build(from: model)

        guard let datas = result.0 else {
            return .failure(.message(result.1 ?? "数据分析还在测试阶段，很快就能上线，敬请期待！"))
        }

        return .success(
            LoadChartDataOutput(
                funcType: model.funcType,
                datas: datas
            )
        )
    }
}
