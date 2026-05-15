import { HistoryRecord } from '../../../core/model/ContractModelExports'

export interface HistoryRepository {
  loadHistoryPage(currentPage: number, pageSize: number): Promise<Array<HistoryRecord>>
}

export class MockHistoryRepository implements HistoryRepository {
  async loadHistoryPage(currentPage: number, pageSize: number): Promise<Array<HistoryRecord>> {
    return mockHistoryRecords()
  }
}

export function mockHistoryRecords(): Array<HistoryRecord> {
  let today = todayString()
  let thisMonth = `${today.substring(0, 8)}01`
  return [
    {
      id: 1001,
      name: '查看一月销售额',
      createTime: `${today} 09:15:00`,
      updateTime: `${today} 09:16:00`,
      detailList: null
    },
    {
      id: 1002,
      name: '仓库库存分析',
      createTime: `${thisMonth} 14:20:00`,
      updateTime: `${thisMonth} 14:21:00`,
      detailList: null
    },
    {
      id: 1003,
      name: '应收账款排行',
      createTime: '2026-01-31 10:00:00',
      updateTime: '2026-01-31 10:01:00',
      detailList: null
    }
  ]
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
