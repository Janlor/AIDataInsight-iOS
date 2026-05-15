import { describe, it, expect } from '@ohos/hypium'
import { HistoryRecord } from '../../main/ets/core/model/ContractModelExports'
import { buildHistorySections, makeHistoryUiState } from '../../main/ets/feature/history/application/HistoryState'

export default function historyStateTest() {
  describe('historyStateTest', () => {
    it('groups history records into today this month and other', 0, () => {
      let today = todayString()
      let thisMonth = `${today.substring(0, 8)}01`
      let records: Array<HistoryRecord> = [
        historyRecord(1, '今天的问题', `${today} 09:10:00`),
        historyRecord(2, '本月的问题', `${thisMonth} 10:20:00`),
        historyRecord(3, '更早的问题', '2026-01-01 11:30:00')
      ]

      let sections = buildHistorySections(records)

      expect(sections.length).assertEqual(3)
      expect(sections[0].title).assertEqual('今天')
      expect(sections[0].items[0].displayTime).assertEqual('09:10')
      expect(sections[1].title).assertEqual('本月')
      expect(sections[1].items[0].displayTime).assertEqual(thisMonth.substring(5, 10))
      expect(sections[2].title).assertEqual('其它')
      expect(sections[2].items[0].displayTime).assertEqual('2026-01-01')
    })

    it('keeps visible records during refresh state', 0, () => {
      let state = makeHistoryUiState([
        historyRecord(1, '已有会话', `${todayString()} 09:10:00`)
      ], true)

      expect(state.sections.length).assertEqual(1)
      expect(state.isRefreshing).assertTrue()
      expect(state.isLoading).assertFalse()
    })
  })
}

function historyRecord(id: number, name: string, updateTime: string): HistoryRecord {
  return {
    id: id,
    name: name,
    createTime: updateTime,
    updateTime: updateTime,
    detailList: null
  }
}

function todayString(): string {
  let now = new Date()
  let month = twoDigits(now.getMonth() + 1)
  let day = twoDigits(now.getDate())
  return `${now.getFullYear()}-${month}-${day}`
}

function twoDigits(value: number): string {
  if (value < 10) {
    return `0${value}`
  }
  return `${value}`
}
