import { HistoryRecord } from '../../../core/model/ContractModelExports'
import { HistoryRepository, MockHistoryRepository } from './HistoryRepository'
import { HistoryUiState, initialHistoryUiState, makeHistoryUiState } from './HistoryState'

export class HistoryRuntimeStore {
  private repository: HistoryRepository
  private records: Array<HistoryRecord> = new Array<HistoryRecord>()
  private loaded: boolean = false

  constructor(repository: HistoryRepository = new MockHistoryRepository()) {
    this.repository = repository
  }

  snapshot(): HistoryUiState {
    if (!this.loaded) {
      return initialHistoryUiState()
    }
    return makeHistoryUiState(this.records, false)
  }

  async refresh(): Promise<HistoryUiState> {
    this.records = await this.repository.loadHistoryPage(1, 20)
    this.loaded = true
    return makeHistoryUiState(this.records, false)
  }

  hasLoadedRecords(): boolean {
    return this.loaded && this.records.length > 0
  }
}

export const historyRuntimeStore = new HistoryRuntimeStore()
