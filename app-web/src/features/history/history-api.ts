import type { HistoryRecord, RecordPage } from '@/contracts/generated/models';
import { request } from '@/data/http/http-client';
import type { HistoryPageInput } from './history-types';

export function loadHistoryPage(input: HistoryPageInput) {
  return request<RecordPage>('/history/page', {
    method: 'GET',
    query: {
      currentPage: input.currentPage,
      pageSize: input.pageSize,
    },
  });
}

export function loadHistoryDetail(historyId: number) {
  return request<HistoryRecord>('/history/detail', {
    method: 'GET',
    query: { historyId },
  });
}

export function deleteHistory(historyId: number) {
  return request<null>('/history/delete', {
    method: 'GET',
    query: { historyId },
  });
}

export function deleteAllHistory() {
  return request<null>('/history/deleteAll', {
    method: 'GET',
  });
}
