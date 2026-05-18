import Testing
import AppContracts
import SwiftData
@testable import AppPersistence

@Test func persistenceBoundaryKeepsTokensOutOfSwiftData() throws {
    #expect(PersistenceBoundary.sensitiveSessionStorage == "Keychain")
    #expect(PersistenceBoundary.nonSensitiveCacheStorage == "SwiftData")
}

@MainActor
@Test func inMemoryContainerCachesHistoryRecords() throws {
    let container = try AppModelContainerFactory.makeInMemory()
    let repository = SwiftDataHistoryCacheRepository(context: ModelContext(container))
    let records = [
        HistoryRecordContract(
            id: 1,
            name: "销售分析",
            detailList: [
                HistoryDetailContract(
                    id: 11,
                    historyId: 1,
                    type: .question,
                    contentType: .ai,
                    content: "查询本月销售"
                ),
                HistoryDetailContract(
                    id: 12,
                    historyId: 1,
                    type: .answer,
                    contentType: .chart,
                    content: "图表结果"
                ),
            ]
        ),
    ]

    try repository.replaceAll(with: records)
    let cached = try repository.list()

    #expect(cached.count == 1)
    #expect(cached.first?.id == 1)
    #expect(cached.first?.detailList?.count == 2)
}

@MainActor
@Test func templateQuestionCacheUpsertsQuestionSet() throws {
    let container = try AppModelContainerFactory.makeInMemory()
    let repository = SwiftDataTemplateQuestionCacheRepository(context: ModelContext(container))

    try repository.save(TemplateQuestionSetContract(questions: ["A", "B"]), cacheKey: "home")
    try repository.save(TemplateQuestionSetContract(questions: ["C"]), cacheKey: "home")

    #expect(try repository.load(cacheKey: "home")?.questions == ["C"])
}

@MainActor
@Test func userPreferenceRepositorySavesAndDeletesPreference() throws {
    let container = try AppModelContainerFactory.makeInMemory()
    let repository = SwiftDataUserPreferenceRepository(context: ModelContext(container))

    try repository.save(UserPreferenceRecord(key: "language", value: "zh-Hans"))
    #expect(try repository.load(key: "language")?.value == "zh-Hans")

    try repository.delete(key: "language")
    #expect(try repository.load(key: "language") == nil)
}
