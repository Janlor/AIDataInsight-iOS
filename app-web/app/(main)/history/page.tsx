'use client';

import Link from 'next/link';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { Trash2 } from 'lucide-react';
import { useMemo, useState } from 'react';
import { PageHeader } from '@/components/page-header';
import { StatusPanel } from '@/components/status-panel';
import { deleteAllHistory, deleteHistory } from '@/features/history/history-api';
import type { HistorySection } from '@/features/history/history-types';
import { useHistoryPage } from '@/features/history/use-history-page';
import { useI18n } from '@/i18n/use-i18n';

export default function HistoryPage() {
  const { t } = useI18n();
  const historyQuery = useHistoryPage();
  const queryClient = useQueryClient();
  const [deletedIds, setDeletedIds] = useState<Set<string>>(() => new Set());
  const [isLocallyCleared, setLocallyCleared] = useState(false);
  const sections = useMemo(
    () => (isLocallyCleared ? [] : removeDeletedItems(historyQuery.data ?? [], deletedIds)),
    [deletedIds, historyQuery.data, isLocallyCleared],
  );
  const refreshHistory = () => {
    void queryClient.invalidateQueries({ queryKey: ['history'] });
  };
  const deleteOneMutation = useMutation({
    mutationFn: deleteHistory,
    onSuccess: (_, historyId) => {
      setLocallyCleared(false);
      setDeletedIds((current) => new Set(current).add(String(historyId)));
      refreshHistory();
    },
  });
  const deleteAllMutation = useMutation({
    mutationFn: deleteAllHistory,
    onSuccess: () => {
      setLocallyCleared(true);
      setDeletedIds(new Set());
      refreshHistory();
    },
  });

  return (
    <>
      <PageHeader
        title={t.history.title}
        description={t.history.description}
        action={
          sections.length > 0 ? (
            <button
              className="inline-flex h-10 items-center gap-2 rounded-control border border-separator bg-surface-primary px-4 text-sm font-medium text-label-secondary transition hover:text-label-primary disabled:opacity-50"
              type="button"
              disabled={deleteAllMutation.isPending}
              onClick={() => deleteAllMutation.mutate()}
            >
              <Trash2 aria-hidden="true" size={16} />
              {t.history.clear}
            </button>
          ) : null
        }
      />

      {historyQuery.isLoading ? (
        <StatusPanel title={t.history.loadingTitle} description={t.history.loadingDescription} />
      ) : null}

      {historyQuery.isError ? (
        <StatusPanel
          title={t.history.errorTitle}
          description={t.history.errorDescription}
        />
      ) : null}

      {!historyQuery.isLoading && !historyQuery.isError && sections.length === 0 ? (
        <StatusPanel title={t.history.emptyTitle} description={t.history.emptyDescription} />
      ) : null}

      <div className="space-y-5">
        {sections.map((section) => (
          <section key={section.kind}>
            <h2 className="mb-2 text-sm font-semibold text-label-secondary">
              {t.sidebar.sections[section.kind]}
            </h2>
            <div className="overflow-hidden rounded-lg border border-separator bg-surface-primary shadow-sm">
              {section.items.map((item) => {
                const historyId = Number(item.id);
                return (
                  <div
                    key={item.id}
                    className="flex items-center gap-3 border-b border-separator px-4 py-3 text-sm last:border-b-0 hover:bg-surface-secondary"
                  >
                    <Link
                      className="min-w-0 flex-1 truncate font-medium text-label-primary"
                      href={`/ai?historyId=${item.id}`}
                    >
                      {item.title}
                    </Link>
                    <span className="shrink-0 text-label-tertiary">{item.displayTime}</span>
                    <button
                      aria-label={t.history.delete}
                      className="flex h-8 w-8 shrink-0 items-center justify-center rounded-control text-label-tertiary transition hover:bg-mark-muted hover:text-mark disabled:opacity-50"
                      type="button"
                      disabled={deleteOneMutation.isPending || !Number.isFinite(historyId)}
                      onClick={() => deleteOneMutation.mutate(historyId)}
                    >
                      <Trash2 aria-hidden="true" size={15} />
                    </button>
                  </div>
                );
              })}
            </div>
          </section>
        ))}
      </div>
    </>
  );
}

function removeDeletedItems(sections: HistorySection[], deletedIds: Set<string>) {
  return sections
    .map((section) => ({
      ...section,
      items: section.items.filter((item) => !deletedIds.has(item.id)),
    }))
    .filter((section) => section.items.length > 0);
}
