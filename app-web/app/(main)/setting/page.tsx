'use client';

import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { LogOut } from 'lucide-react';
import { PageHeader } from '@/components/page-header';
import { useAccountStore } from '@/data/account/session-store';
import { useI18n } from '@/i18n/use-i18n';

export default function SettingPage() {
  const router = useRouter();
  const { t } = useI18n();
  const session = useAccountStore((state) => state.session);
  const user = useAccountStore((state) => state.user);
  const logout = useAccountStore((state) => state.logout);

  return (
    <>
      <PageHeader title={t.setting.title} description={t.login.formHelp} />

      <section className="rounded-lg border border-separator bg-surface-primary p-5 shadow-sm">
        <h2 className="text-base font-semibold text-label-primary">{t.setting.sections.account}</h2>
        <dl className="mt-4 grid gap-4 text-sm sm:grid-cols-2">
          <div>
            <dt className="text-label-tertiary">{t.setting.rows.username}</dt>
            <dd className="mt-1 font-medium text-label-primary">
              {user?.username ?? session.username ?? '-'}
            </dd>
          </div>
          <div>
            <dt className="text-label-tertiary">Org</dt>
            <dd className="mt-1 font-medium text-label-primary">{session.orgId ?? '-'}</dd>
          </div>
        </dl>
      </section>

      <section className="mt-4 rounded-lg border border-separator bg-surface-primary p-5 shadow-sm">
        <h2 className="text-base font-semibold text-label-primary">{t.setting.sections.about}</h2>
        <div className="mt-4 flex flex-wrap gap-3">
          <Link
            className="inline-flex h-10 items-center rounded-control border border-separator px-4 text-sm font-medium text-label-secondary transition hover:text-label-primary"
            href="/privacy"
          >
            {t.setting.rows.privacy}
          </Link>
          <button
            className="inline-flex h-10 items-center gap-2 rounded-control bg-label-primary px-4 text-sm font-medium text-white transition hover:bg-label-secondary"
            type="button"
            onClick={() => {
              void logout().finally(() => router.replace('/login'));
            }}
          >
            <LogOut aria-hidden="true" size={17} />
            {t.setting.rows.logout}
          </button>
        </div>
      </section>
    </>
  );
}
