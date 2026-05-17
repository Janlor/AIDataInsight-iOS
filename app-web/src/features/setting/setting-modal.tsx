'use client';

import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { ChevronRight, Loader2, X } from 'lucide-react';
import { useMemo, useState } from 'react';
import type { SettingRow } from '@/contracts/generated/models';
import { useAccountStore } from '@/data/account/session-store';
import { buildSettingStateFromContract } from './setting-contract';

export function SettingModal({ open, onClose }: { open: boolean; onClose: () => void }) {
  const router = useRouter();
  const session = useAccountStore((state) => state.session);
  const user = useAccountStore((state) => state.user);
  const logout = useAccountStore((state) => state.logout);
  const [isConfirmingLogout, setConfirmingLogout] = useState(false);
  const [isLoggingOut, setLoggingOut] = useState(false);
  const settingState = useMemo(
    () => buildSettingStateFromContract({ session, user }),
    [session, user],
  );

  if (!open) {
    return null;
  }

  async function confirmLogout() {
    setLoggingOut(true);
    await logout().finally(() => {
      setLoggingOut(false);
      setConfirmingLogout(false);
      onClose();
      router.replace('/login');
    });
  }

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center bg-black/35 p-0 sm:items-center sm:p-6">
      <div
        aria-labelledby="setting-modal-title"
        aria-modal="true"
        className="max-h-[88vh] w-full overflow-hidden rounded-t-lg border border-separator bg-white shadow-xl sm:max-w-lg sm:rounded-lg"
        role="dialog"
      >
        <header className="flex h-14 items-center justify-between border-b border-separator px-4">
          <h2 id="setting-modal-title" className="text-base font-semibold text-label-primary">
            {settingState.title}
          </h2>
          <button
            aria-label="关闭设置"
            className="flex h-9 w-9 items-center justify-center rounded-control text-label-secondary transition hover:bg-surface-secondary hover:text-label-primary"
            type="button"
            onClick={onClose}
          >
            <X aria-hidden="true" size={18} />
          </button>
        </header>

        <div className="max-h-[calc(88vh-3.5rem)] overflow-y-auto bg-surface-secondary px-4 py-4">
          <div className="space-y-4">
            {settingState.sections.map((section) => (
              <section key={section.kind}>
                {section.title ? (
                  <h3 className="mb-2 px-1 text-xs font-semibold text-label-tertiary">{section.title}</h3>
                ) : null}
                <div className="overflow-hidden rounded-lg border border-separator bg-white">
                  {section.rows.map((row) => (
                    <SettingRowItem
                      key={row.kind}
                      row={row}
                      disabled={isLoggingOut}
                      onClose={onClose}
                      onConfirmLogout={() => setConfirmingLogout(true)}
                    />
                  ))}
                </div>
              </section>
            ))}
          </div>
        </div>
      </div>

      {isConfirmingLogout ? (
        <div className="fixed inset-0 z-10 flex items-center justify-center bg-black/30 p-4">
          <div className="w-full max-w-sm rounded-lg bg-white p-5 shadow-xl">
            <h3 className="text-base font-semibold text-label-primary">
              {settingState.logoutDialog.title}
            </h3>
            <div className="mt-5 flex justify-end gap-2">
              <button
                className="h-10 rounded-control border border-separator px-4 text-sm font-medium text-label-secondary transition hover:text-label-primary"
                type="button"
                disabled={isLoggingOut}
                onClick={() => setConfirmingLogout(false)}
              >
                {settingState.logoutDialog.cancelTitle}
              </button>
              <button
                className="inline-flex h-10 items-center gap-2 rounded-control bg-mark px-4 text-sm font-medium text-white transition hover:bg-red-700 disabled:opacity-60"
                type="button"
                disabled={isLoggingOut}
                onClick={() => {
                  void confirmLogout();
                }}
              >
                {isLoggingOut ? <Loader2 aria-hidden="true" className="animate-spin" size={16} /> : null}
                {settingState.logoutDialog.confirmTitle}
              </button>
            </div>
          </div>
        </div>
      ) : null}
    </div>
  );
}

function SettingRowItem({
  row,
  disabled,
  onClose,
  onConfirmLogout,
}: {
  row: SettingRow;
  disabled: boolean;
  onClose: () => void;
  onConfirmLogout: () => void;
}) {
  const className = [
    'flex min-h-12 w-full items-center gap-3 border-b border-separator px-4 py-3 text-sm last:border-b-0',
    row.centered ? 'justify-center text-center' : 'justify-between text-left',
    row.selectable ? 'transition hover:bg-surface-secondary' : '',
    row.destructive ? 'font-medium text-mark' : 'text-label-primary',
  ].join(' ');

  if (row.action === 'openPrivacy') {
    return (
      <Link className={className} href="/privacy" onClick={onClose}>
        <span>{row.title}</span>
        <span className="flex items-center gap-2 text-label-tertiary">
          {row.detail}
          {row.showsDisclosure ? <ChevronRight aria-hidden="true" size={16} /> : null}
        </span>
      </Link>
    );
  }

  if (row.action === 'confirmLogout') {
    return (
      <button className={className} type="button" disabled={disabled} onClick={onConfirmLogout}>
        {row.title}
      </button>
    );
  }

  return (
    <div className={className}>
      <span>{row.title}</span>
      <span className="text-label-secondary">{row.detail}</span>
    </div>
  );
}
