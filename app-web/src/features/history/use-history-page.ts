'use client';

import { useQuery } from '@tanstack/react-query';
import { loadHistoryPage } from './history-api';
import { mapRecordPageToSections } from './history-mappers';

export function useHistoryPage() {
  return useQuery({
    queryKey: ['history', 'page', 1, 20],
    queryFn: () => loadHistoryPage({ currentPage: 1, pageSize: 20 }),
    select: (page) => mapRecordPageToSections(page),
  });
}
