export interface HistoryPageInput {
  currentPage: number;
  pageSize: number;
}

export interface HistorySectionItem {
  id: string;
  title: string;
  displayTime: string;
}

export interface HistorySection {
  kind: 'today' | 'thisMonth' | 'other';
  title: string;
  items: HistorySectionItem[];
}
