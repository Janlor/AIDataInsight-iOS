import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import type { AccountSession, AccountUser } from '@/contracts/generated/models';
import { emptySession } from './account-types';
import { useAccountStore } from './session-store';

const storageKey = 'aidatainsight.web.account';

describe('useAccountStore', () => {
  beforeEach(() => {
    installLocalStorageMock();
  });

  afterEach(() => {
    vi.restoreAllMocks();
    vi.unstubAllGlobals();
    useAccountStore.setState({ session: emptySession, user: null, isHydrated: false });
  });

  it('persists AccountUser after successful getUserInfo refresh', async () => {
    const session: AccountSession = {
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
      orgId: 7,
      username: 'cached-user',
      isLogin: true,
    };
    const cachedUser: AccountUser = {
      id: 1,
      username: 'cached-user',
      nickname: 'Cached',
      phone: null,
    };
    const freshUser: AccountUser = {
      id: 1,
      username: 'fresh-user',
      nickname: 'Fresh',
      phone: '13800000000',
    };

    useAccountStore.setState({ session, user: cachedUser, isHydrated: true });
    vi.stubGlobal(
      'fetch',
      vi.fn().mockResolvedValue(jsonResponse({ code: 200, msg: 'ok', data: freshUser })),
    );

    await useAccountStore.getState().loadUserInfo();

    expect(useAccountStore.getState().user).toEqual(freshUser);
    expect(useAccountStore.getState().session.username).toBe('fresh-user');
    expect(JSON.parse(window.localStorage.getItem(storageKey) ?? '{}')).toMatchObject({
      session: { accessToken: 'access-token', username: 'fresh-user', isLogin: true },
      user: freshUser,
    });
  });

  it('clears cached AccountUser together with AccountSession', () => {
    useAccountStore.setState({
      session: {
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
        orgId: 7,
        username: 'demo',
        isLogin: true,
      },
      user: { id: 1, username: 'demo', nickname: 'Demo', phone: null },
      isHydrated: true,
    });
    window.localStorage.setItem(storageKey, JSON.stringify(useAccountStore.getState()));

    useAccountStore.getState().clearSession();

    expect(useAccountStore.getState().session).toEqual(emptySession);
    expect(useAccountStore.getState().user).toBeNull();
    expect(window.localStorage.getItem(storageKey)).toBeNull();
  });
});

function jsonResponse(body: unknown) {
  return new Response(JSON.stringify(body), {
    status: 200,
    headers: { 'Content-Type': 'application/json' },
  });
}

function installLocalStorageMock() {
  const storage = new Map<string, string>();
  Object.defineProperty(window, 'localStorage', {
    configurable: true,
    value: {
      getItem: vi.fn((key: string) => storage.get(key) ?? null),
      setItem: vi.fn((key: string, value: string) => {
        storage.set(key, value);
      }),
      removeItem: vi.fn((key: string) => {
        storage.delete(key);
      }),
      clear: vi.fn(() => {
        storage.clear();
      }),
    },
  });
}
