'use client';

import Link from 'next/link';
import { usePathname, useRouter, useSearchParams } from 'next/navigation';
import { LogOut, MessageSquarePlus, Settings } from 'lucide-react';
import { useAccountStore } from '@/data/account/session-store';
import { useHistoryPage } from '@/features/history/use-history-page';

export function ChatSidebar() {
  const pathname = usePathname();
  const searchParams = useSearchParams();
  const router = useRouter();
  const logout = useAccountStore((state) => state.logout);
  const historyQuery = useHistoryPage();
  const activeHistoryId = searchParams.get('historyId');
  const sections = historyQuery.data ?? [];

  return (
    <aside className="fixed inset-y-0 left-0 hidden w-72 flex-col border-r border-separator bg-white lg:flex">
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
                        ? 'bg-blue-50 text-accent-primary'
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
        <Link
          className="flex h-10 items-center gap-3 rounded-control px-3 text-sm font-medium text-label-secondary transition hover:bg-surface-secondary hover:text-label-primary"
          href="/setting"
        >
          <Settings aria-hidden="true" size={18} />
          设置
        </Link>
        <button
          className="mt-1 flex h-10 w-full items-center gap-3 rounded-control px-3 text-sm font-medium text-label-secondary transition hover:bg-surface-secondary hover:text-label-primary"
          type="button"
          onClick={() => {
            void logout().finally(() => router.replace('/login'));
          }}
        >
          <LogOut aria-hidden="true" size={18} />
          退出登录
        </button>
      </div>
    </aside>
  );
}
