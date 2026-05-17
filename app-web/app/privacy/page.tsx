'use client';

import Link from 'next/link';
import { useEffect } from 'react';
import { privacyPolicyContent } from '@/contracts/generated/models';
import { useAccountStore } from '@/data/account/session-store';

export default function PrivacyPage() {
  const session = useAccountStore((state) => state.session);
  const isHydrated = useAccountStore((state) => state.isHydrated);
  const hydrate = useAccountStore((state) => state.hydrate);

  useEffect(() => {
    hydrate();
  }, [hydrate]);

  const returnHref = isHydrated && session.isLogin ? '/ai' : '/login';
  const returnText = isHydrated && session.isLogin ? '返回工作台' : '返回登录';

  return (
    <main className="min-h-screen bg-surface-secondary px-4 py-8">
      <article className="mx-auto max-w-3xl rounded-lg border border-separator bg-surface-primary p-6 shadow-sm">
        <h1 className="text-2xl font-semibold text-label-primary">{privacyPolicyContent.title}</h1>
        <p className="mt-2 text-sm text-label-tertiary">更新日期：{privacyPolicyContent.updatedAt}</p>
        <div className="mt-6 space-y-6">
          {privacyPolicyContent.sections.map((section) => (
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
