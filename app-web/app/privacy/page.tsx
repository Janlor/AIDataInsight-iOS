'use client';

import Link from 'next/link';
import { useEffect } from 'react';
import { useAccountStore } from '@/data/account/session-store';
import { useI18n } from '@/i18n/use-i18n';

export default function PrivacyPage() {
  const session = useAccountStore((state) => state.session);
  const { t } = useI18n();
  const isHydrated = useAccountStore((state) => state.isHydrated);
  const hydrate = useAccountStore((state) => state.hydrate);

  useEffect(() => {
    hydrate();
  }, [hydrate]);

  const returnHref = isHydrated && session.isLogin ? '/ai' : '/login';
  const returnText = isHydrated && session.isLogin ? t.privacy.returnWorkspace : t.privacy.returnLogin;

  return (
    <main className="min-h-screen bg-surface-secondary px-4 py-8">
      <article className="mx-auto max-w-3xl rounded-lg border border-separator bg-surface-primary p-6 shadow-sm">
        <h1 className="text-2xl font-semibold text-label-primary">{t.privacy.title}</h1>
        <p className="mt-2 text-sm text-label-tertiary">{t.privacy.updatedAtLabel}：2026-05-18</p>
        <div className="mt-6 space-y-6">
          {t.privacy.sections.map((section) => (
            <section key={section.heading}>
              <h2 className="text-base font-semibold text-label-primary">{section.heading}</h2>
              <div className="mt-2 space-y-2">
                {section.paragraphs.map((paragraph) => (
                  <p key={paragraph} className="text-sm leading-7 text-label-secondary">
                    {paragraph}
                  </p>
                ))}
              </div>
            </section>
          ))}
        </div>
        <div className="mt-6">
          <Link
            className="inline-flex h-10 items-center rounded-control bg-accent-primary px-4 text-sm font-medium text-white"
            href={returnHref}
          >
            {returnText}
          </Link>
        </div>
      </article>
    </main>
  );
}
