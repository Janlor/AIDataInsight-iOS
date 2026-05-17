'use client';

import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { LogOut } from 'lucide-react';
import { PageHeader } from '@/components/page-header';
import { useAccountStore } from '@/data/account/session-store';

export default function SettingPage() {
  const router = useRouter();
  const session = useAccountStore((state) => state.session);
  const user = useAccountStore((state) => state.user);
  const logout = useAccountStore((state) => state.logout);

  return (
    <>
      <PageHeader title="设置" description="账户信息、隐私协议和退出登录入口。" />

      <section className="rounded-lg border border-separator bg-surface-primary p-5 shadow-sm">
        <h2 className="text-base font-semibold text-label-primary">账户</h2>
        <dl className="mt-4 grid gap-4 text-sm sm:grid-cols-2">
          <div>
            <dt className="text-label-tertiary">用户名</dt>
            <dd className="mt-1 font-medium text-label-primary">
              {user?.username ?? session.username ?? '-'}
            </dd>
          </div>
          <div>
            <dt className="text-label-tertiary">组织</dt>
            <dd className="mt-1 font-medium text-label-primary">{session.orgId ?? '-'}</dd>
          </div>
        </dl>
      </section>

      <section className="mt-4 rounded-lg border border-separator bg-surface-primary p-5 shadow-sm">
        <h2 className="text-base font-semibold text-label-primary">应用</h2>
        <div className="mt-4 flex flex-wrap gap-3">
          <Link
            className="inline-flex h-10 items-center rounded-control border border-separator px-4 text-sm font-medium text-label-secondary transition hover:text-label-primary"
            href="/privacy"
          >
            隐私协议
          </Link>
          <button
            className="inline-flex h-10 items-center gap-2 rounded-control bg-label-primary px-4 text-sm font-medium text-white transition hover:bg-label-secondary"
            type="button"
            onClick={() => {
              void logout().finally(() => router.replace('/login'));
            }}
          >
            <LogOut aria-hidden="true" size={17} />
            退出登录
          </button>
        </div>
      </section>
    </>
  );
}
