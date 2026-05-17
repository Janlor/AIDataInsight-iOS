'use client';

import Link from 'next/link';
import { usePathname, useSearchParams } from 'next/navigation';
import { MessageSquarePlus } from 'lucide-react';
import { useState } from 'react';
import { useAccountStore } from '@/data/account/session-store';
import { useHistoryPage } from '@/features/history/use-history-page';
import { getDisplayName, getInitials } from '@/features/setting/setting-contract';
import { SettingModal } from '@/features/setting/setting-modal';

export function ChatSidebar() {
  const pathname = usePathname();
  const searchParams = useSearchParams();
  const session = useAccountStore((state) => state.session);
  const user = useAccountStore((state) => state.user);
  const historyQuery = useHistoryPage();
  const [isSettingOpen, setSettingOpen] = useState(false);
  const activeHistoryId = searchParams.get('historyId');
  const sections = historyQuery.data ?? [];
  const displayName = getDisplayName(session, user);
  const initials = getInitials(displayName);

  return (
    <aside className="fixed inset-y-0 left-0 hidden w-72 flex-col border-r border-separator bg-surface-primary lg:flex">
      <div className="border-b border-separator p-3">
        <Link
          className="flex h-10 items-center gap-3 rounded-control px-3 text-sm font-medium text-label-primary transition hover:bg-surface-secondary"
          href="/ai"
        >
          <MessageSquarePlus aria-hidden="true" size={18} />
          New Chat
        </Link>
      </div>

      <div className="flex-1 overflow-y-auto px-3 py-4">
        {historyQuery.isLoading ? (
          <p className="px-3 text-sm text-label-secondary">正在加载历史...</p>
        ) : null}
        {historyQuery.isError ? (
          <p className="px-3 text-sm text-mark">历史加载失败</p>
        ) : null}
        {sections.map((section) => (
          <section key={section.kind} className="mb-5">
            <h2 className="mb-2 px-3 text-xs font-semibold uppercase tracking-normal text-label-tertiary">
              {section.title}
            </h2>
            <div className="space-y-1">
              {section.items.map((item) => {
                const active = pathname === '/ai' && activeHistoryId === item.id;
                return (
                  <Link
                    key={item.id}
                    className={[
                      'block rounded-control px-3 py-2 text-sm transition',
                      active
                        ? 'bg-accent-secondary text-accent-primary'
                        : 'text-label-secondary hover:bg-surface-secondary hover:text-label-primary',
                    ].join(' ')}
                    href={`/ai?historyId=${item.id}`}
                  >
                    <span className="block truncate font-medium">{item.title}</span>
                    <span className="mt-1 block text-xs text-label-tertiary">{item.displayTime}</span>
                  </Link>
                );
              })}
            </div>
          </section>
        ))}
        {!historyQuery.isLoading && !historyQuery.isError && sections.length === 0 ? (
          <p className="px-3 text-sm text-label-secondary">暂无历史记录</p>
        ) : null}
      </div>

      <div className="border-t border-separator p-3">
        <button
          aria-label={`打开设置：${displayName}`}
          className="flex w-full items-center gap-3 rounded-control px-3 py-2 text-left transition hover:bg-surface-secondary"
          type="button"
          onClick={() => setSettingOpen(true)}
        >
          <span className="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-label-primary text-xs font-semibold text-white">
            {initials}
          </span>
          <span className="min-w-0">
            <span className="block truncate text-sm font-medium text-label-primary">{displayName}</span>
            <span className="block truncate text-xs text-label-tertiary">设置与账户</span>
          </span>
        </button>
      </div>

      <SettingModal open={isSettingOpen} onClose={() => setSettingOpen(false)} />
    </aside>
  );
}
