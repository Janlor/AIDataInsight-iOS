'use client';

import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';
import { Bot, History, LogOut, Settings } from 'lucide-react';
import { ReactNode, useEffect } from 'react';
import { useAccountStore } from '@/data/account/session-store';

const navItems = [
  { href: '/ai', label: 'AI', icon: Bot },
  { href: '/history', label: '历史', icon: History },
  { href: '/setting', label: '设置', icon: Settings },
];

export function AppShell({ children }: { children: ReactNode }) {
  const pathname = usePathname();
  const router = useRouter();
  const session = useAccountStore((state) => state.session);
  const user = useAccountStore((state) => state.user);
  const isHydrated = useAccountStore((state) => state.isHydrated);
  const hydrate = useAccountStore((state) => state.hydrate);
  const logout = useAccountStore((state) => state.logout);

  useEffect(() => {
    hydrate();
  }, [hydrate]);

  useEffect(() => {
    if (isHydrated && !session.isLogin) {
      router.replace('/login');
    }
  }, [isHydrated, router, session.isLogin]);

  if (!isHydrated) {
    return (
      <main className="flex min-h-screen items-center justify-center bg-surface-secondary text-sm text-label-secondary">
        正在恢复会话...
      </main>
    );
  }

  if (!session.isLogin) {
    return null;
  }

  return (
    <div className="min-h-screen bg-surface-secondary">
      <aside className="fixed inset-y-0 left-0 hidden w-64 border-r border-separator bg-white px-4 py-5 lg:block">
        <Link className="flex items-center gap-3" href="/ai">
          <span className="flex h-10 w-10 items-center justify-center rounded-control bg-accent-primary text-white">
            <Bot aria-hidden="true" size={22} />
          </span>
          <span className="text-base font-semibold text-label-primary">AIDataInsight</span>
        </Link>

        <nav className="mt-8 space-y-1">
          {navItems.map((item) => {
            const Icon = item.icon;
            const active = pathname === item.href;
            return (
              <Link
                key={item.href}
                className={[
                  'flex h-10 items-center gap-3 rounded-control px-3 text-sm font-medium transition',
                  active
                    ? 'bg-blue-50 text-accent-primary'
                    : 'text-label-secondary hover:bg-surface-secondary hover:text-label-primary',
                ].join(' ')}
                href={item.href}
              >
                <Icon aria-hidden="true" size={18} />
                {item.label}
              </Link>
            );
          })}
        </nav>

        <div className="absolute bottom-5 left-4 right-4">
          <div className="rounded-lg border border-separator bg-surface-secondary p-3">
            <p className="truncate text-sm font-medium text-label-primary">
              {user?.nickname ?? user?.username ?? session.username ?? '已登录用户'}
            </p>
            <p className="mt-1 truncate text-xs text-label-tertiary">Org {session.orgId ?? '-'}</p>
          </div>
          <button
            className="mt-3 flex h-10 w-full items-center justify-center gap-2 rounded-control border border-separator bg-white px-3 text-sm font-medium text-label-secondary transition hover:text-label-primary"
            type="button"
            onClick={() => {
              void logout().finally(() => router.replace('/login'));
            }}
          >
            <LogOut aria-hidden="true" size={17} />
            退出
          </button>
        </div>
      </aside>

      <header className="sticky top-0 z-10 border-b border-separator bg-white/95 px-4 py-3 backdrop-blur lg:hidden">
        <div className="flex items-center justify-between">
          <Link className="flex items-center gap-2 text-sm font-semibold text-label-primary" href="/ai">
            <Bot aria-hidden="true" size={20} />
            AIDataInsight
          </Link>
          <nav className="flex items-center gap-1">
            {navItems.map((item) => {
              const Icon = item.icon;
              const active = pathname === item.href;
              return (
                <Link
                  key={item.href}
                  aria-label={item.label}
                  className={[
                    'flex h-9 w-9 items-center justify-center rounded-control',
                    active ? 'bg-blue-50 text-accent-primary' : 'text-label-secondary',
                  ].join(' ')}
                  href={item.href}
                >
                  <Icon aria-hidden="true" size={18} />
                </Link>
              );
            })}
          </nav>
        </div>
      </header>

      <main className="lg:pl-64">
        <div className="mx-auto w-full max-w-7xl px-4 py-6 sm:px-6 lg:px-8">{children}</div>
      </main>
    </div>
  );
}
