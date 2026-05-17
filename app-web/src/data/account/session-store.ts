'use client';

import { create } from 'zustand';
import type { AccountSession, AccountUser } from '@/contracts/generated/models';
import { configureHttpAuthBridge } from '@/data/http/http-client';
import { toAppError } from '@/domain/errors';
import { getUserInfo, loginAccount, logoutAccount, refreshAccountSession } from './account-api';
import { mergeUserIntoSession, normalizeOAuthSession } from './account-mappers';
import { emptySession, type LoginInput } from './account-types';
import { clearAccountState, readAccountState, writeAccountState } from './session-storage';

interface AccountStore {
  session: AccountSession;
  user: AccountUser | null;
  isHydrated: boolean;
  hydrate: () => void;
  login: (input: LoginInput) => Promise<void>;
  logout: () => Promise<void>;
  refreshToken: () => Promise<boolean>;
  clearSession: () => void;
  loadUserInfo: () => Promise<void>;
}

export const useAccountStore = create<AccountStore>((set, get) => ({
  session: emptySession,
  user: null,
  isHydrated: false,

  hydrate: () => {
    const state = readAccountState();
    set({ ...state, isHydrated: true });
  },

  login: async (input) => {
    const session = await loginAccount(input);
    const nextState = { session, user: null };
    set(nextState);
    writeAccountState(nextState);
    await get().loadUserInfo().catch(() => undefined);
  },

  logout: async () => {
    try {
      await logoutAccount();
    } finally {
      get().clearSession();
    }
  },

  refreshToken: async () => {
    const current = get().session;
    if (!current.refreshToken) {
      get().clearSession();
      return false;
    }

    try {
      const refreshed = await refreshAccountSession(current.refreshToken);
      const session = normalizeOAuthSession(refreshed, current);
      const nextState = { session, user: get().user };
      set(nextState);
      writeAccountState(nextState);
      return session.isLogin;
    } catch (error) {
      const appError = toAppError(error);
      if (appError.code === 401 || appError.code === 402) {
        get().clearSession();
      }
      return false;
    }
  },

  clearSession: () => {
    clearAccountState();
    set({ session: emptySession, user: null, isHydrated: true });
  },

  loadUserInfo: async () => {
    const user = await getUserInfo();
    const session = mergeUserIntoSession(get().session, user);
    const nextState = { session, user };
    set(nextState);
    writeAccountState(nextState);
  },
}));

configureHttpAuthBridge({
  getAccessToken: () => useAccountStore.getState().session.accessToken ?? null,
  refreshToken: () => useAccountStore.getState().refreshToken(),
  clearSession: () => useAccountStore.getState().clearSession(),
});
