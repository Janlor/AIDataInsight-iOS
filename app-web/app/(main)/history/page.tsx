'use client';

import Link from 'next/link';
import { PageHeader } from '@/components/page-header';
import { StatusPanel } from '@/components/status-panel';
import { useHistoryPage } from '@/features/history/use-history-page';

export default function HistoryPage() {
  const historyQuery = useHistoryPage();
  const sections = historyQuery.data ?? [];

  return (
    <>
      <PageHeader
        title="历史记录"
        description="已接入 history/page 数据层，详情恢复会复用 AI Chat 的 history mapper。"
      />

      {historyQuery.isLoading ? (
        <StatusPanel title="正在加载历史记录" description="请稍候。" />
      ) : null}

      {historyQuery.isError ? (
        <StatusPanel
          title="历史记录加载失败"
          description="请检查登录态或网络环境。当前接口层已经按跨端契约保留业务错误码。"
        />
      ) : null}

      {!historyQuery.isLoading && !historyQuery.isError && sections.length === 0 ? (
        <StatusPanel title="暂无历史记录" description="完成一次 AI 对话后，会在这里显示历史会话。" />
      ) : null}

      <div className="space-y-5">
        {sections.map((section) => (
          <section key={section.kind}>
            <h2 className="mb-2 text-sm font-semibold text-label-secondary">{section.title}</h2>
            <div className="overflow-hidden rounded-lg border border-separator bg-white shadow-sm">
              {section.items.map((item) => (
                <Link
                  key={item.id}
                  className="flex items-center justify-between gap-4 border-b border-separator px-4 py-3 text-sm last:border-b-0 hover:bg-surface-secondary"
                  href={`/ai?historyId=${item.id}`}
                >
                  <span className="min-w-0 truncate font-medium text-label-primary">{item.title}</span>
                  <span className="shrink-0 text-label-tertiary">{item.displayTime}</span>
                </Link>
              ))}
            </div>
          </section>
        ))}
      </div>
    </>
  );
}
