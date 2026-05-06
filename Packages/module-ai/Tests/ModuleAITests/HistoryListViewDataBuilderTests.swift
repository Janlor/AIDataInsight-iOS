import Foundation
import Testing
@testable import ModuleAI

struct HistoryListViewDataBuilderTests {
    @Test
    func groupRecords_splitsTodayThisMonthAndOther() {
        let formatter = makeDateFormatter()
        let now = Date()
        let calendar = Calendar.current
        let today = record(id: 1, name: "今天记录", updateTime: formatter.string(from: now))
        let thisMonth = record(
            id: 2,
            name: "本月记录",
            updateTime: formatter.string(from: calendar.date(byAdding: .day, value: -2, to: now) ?? now)
        )
        let other = record(
            id: 3,
            name: "更早记录",
            updateTime: formatter.string(from: calendar.date(byAdding: .month, value: -2, to: now) ?? now)
        )

        let groups = HistoryListViewDataBuilder.groupRecords([today, thisMonth, other], dateFormatter: formatter)

        #expect(groups.count == 3)
        #expect(groups[0].records.map(\.id) == [1])
        #expect(groups[1].records.map(\.id) == [2])
        #expect(groups[2].records.map(\.id) == [3])
        if case .today = groups[0].kind {} else { Issue.record("Expected first group to be today") }
        if case .thisMonth = groups[1].kind {} else { Issue.record("Expected second group to be thisMonth") }
        if case .other = groups[2].kind {} else { Issue.record("Expected third group to be other") }
    }

    @Test
    func mergeGroups_appendsRecordsIntoExistingKind() {
        var existing = [
            HistoryRecordGroup(
                kind: .today,
                records: [record(id: 1, name: "A", updateTime: "2025-01-31 10:30:00")]
            )
        ]
        let newGroups = [
            HistoryRecordGroup(
                kind: .today,
                records: [record(id: 2, name: "B", updateTime: "2025-01-31 11:30:00")]
            ),
            HistoryRecordGroup(
                kind: .other,
                records: [record(id: 3, name: "C", updateTime: "2024-12-01 09:00:00")]
            )
        ]

        HistoryListViewDataBuilder.mergeGroups(existing: &existing, new: newGroups)

        #expect(existing.count == 2)
        #expect(existing[0].records.map(\.id) == [1, 2])
        #expect(existing[1].records.map(\.id) == [3])
    }

    @Test
    func makeSections_buildsItemTextFromRecord() {
        let grouped = [
            HistoryRecordGroup(
                kind: .today,
                records: [record(id: 9, name: "销售分析", updateTime: "2025-01-31 10:30:45")]
            )
        ]

        let sections = HistoryListViewDataBuilder.makeSections(from: grouped)

        #expect(sections.count == 1)
        #expect(sections[0].items.count == 1)
        #expect(sections[0].items[0].id == 9)
        #expect(sections[0].items[0].titleText.string.contains("销售分析"))
        #expect(sections[0].items[0].titleText.string.contains("10:30"))
    }
}

private extension HistoryListViewDataBuilderTests {
    func makeDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }

    func record(id: Int, name: String, updateTime: String) -> RecordModel {
        RecordModel(
            id: id,
            name: name,
            createId: nil,
            updateId: nil,
            createName: nil,
            updateName: nil,
            createTime: nil,
            updateTime: updateTime,
            detailList: nil
        )
    }
}
