import type { AccountUser } from '@/contracts/generated/models';
import { emptySession, type AccountState } from './account-types';

const STORAGE_KEY = 'aidatainsight.web.account';

export function readAccountState(): AccountState {
  if (typeof window === 'undefined') {
    return { session: emptySession, user: null };
  }

  const raw = window.localStorage.getItem(STORAGE_KEY);
  if (!raw) {
    return { session: emptySession, user: null };
  }

  try {
    const parsed = JSON.parse(raw) as Partial<AccountState>;
    const accessToken = parsed.session?.accessToken ?? null;
    return {
      session: {
        accessToken,
        refreshToken: parsed.session?.refreshToken ?? null,
        orgId: parsed.session?.orgId ?? null,
        username: parsed.session?.username ?? null,
        isLogin: Boolean(accessToken),
      },
      user: normalizeUser(parsed.user),
    };
  } catch {
    clearAccountState();
    return { session: emptySession, user: null };
  }
}

export function writeAccountState(state: AccountState) {
  if (typeof window === 'undefined') {
    return;
  }
  window.localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
}

export function clearAccountState() {
  if (typeof window === 'undefined') {
    return;
  }
  window.localStorage.removeItem(STORAGE_KEY);
}

function normalizeUser(user: AccountUser | null | undefined): AccountUser | null {
  if (!user) {
    return null;
  }
  return user;
}
