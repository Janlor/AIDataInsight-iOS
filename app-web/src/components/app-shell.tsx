'use client';

import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';
import { Bot, MessageSquarePlus, Settings } from 'lucide-react';
import { ReactNode, useEffect } from 'react';
import { useAccountStore } from '@/data/account/session-store';
import { ChatSidebar } from './chat-sidebar';

const navItems = [
  { href: '/ai', label: 'New Chat', icon: MessageSquarePlus },
  { href: '/setting', label: '设置', icon: Settings },
];

export function AppShell({ children }: { children: ReactNode }) {
  const pathname = usePathname();
  const router = useRouter();
  const session = useAccountStore((state) => state.session);
  const isHydrated = useAccountStore((state) => state.isHydrated);
  const hydrate = useAccountStore((state) => state.hydrate);

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
      <ChatSidebar />

      <header className="sticky top-0 z-10 border-b border-separator bg-surface-primary/95 px-4 py-3 backdrop-blur lg:hidden">
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
                    active ? 'bg-accent-secondary text-accent-primary' : 'text-label-secondary',
                  ].join(' ')}
                  href={item.href}
                  onClick={
                    item.href === '/ai'
                      ? (event) => {
                          event.preventDefault();
                          router.push(`/ai?newChat=${Date.now()}`);
                        }
                      : undefined
                  }
                >
                  <Icon aria-hidden="true" size={18} />
                </Link>
              );
            })}
          </nav>
        </div>
      </header>

      <main className="lg:pl-72">
        <div className="mx-auto w-full max-w-6xl px-4 py-6 sm:px-6 lg:px-8">{children}</div>
      </main>
    </div>
  );
}
