import { afterEach, describe, expect, it, vi } from 'vitest';
import { configureHttpAuthBridge, request } from './http-client';

describe('http-client', () => {
  afterEach(() => {
    vi.restoreAllMocks();
  });

  it('refreshes token and retries original request once when business code is 402', async () => {
    const fetchMock = vi
      .fn()
      .mockResolvedValueOnce(jsonResponse({ code: 402, msg: 'access token expired', data: null }))
      .mockResolvedValueOnce(jsonResponse({ code: 200, msg: 'ok', data: { value: 1 } }));

    vi.stubGlobal('fetch', fetchMock);

    const refreshToken = vi.fn().mockResolvedValue(true);
    configureHttpAuthBridge({
      getAccessToken: () => 'access-token',
      refreshToken,
      clearSession: vi.fn(),
    });

    await expect(request<{ value: number }>('/demo', { method: 'GET' })).resolves.toEqual({ value: 1 });
    expect(refreshToken).toHaveBeenCalledTimes(1);
    expect(fetchMock).toHaveBeenCalledTimes(2);
  });

  it('clears session when business code is 401', async () => {
    vi.stubGlobal(
      'fetch',
      vi.fn().mockResolvedValue(jsonResponse({ code: 401, msg: '登录已失效', data: null })),
    );

    const clearSession = vi.fn();
    configureHttpAuthBridge({
      getAccessToken: () => 'access-token',
      refreshToken: vi.fn(),
      clearSession,
    });

    await expect(request('/demo', { method: 'GET' })).rejects.toMatchObject({
      kind: 'server',
      code: 401,
    });
    expect(clearSession).toHaveBeenCalledTimes(1);
  });
});

function jsonResponse(body: unknown) {
  return new Response(JSON.stringify(body), {
    status: 200,
    headers: { 'Content-Type': 'application/json' },
  });
}
