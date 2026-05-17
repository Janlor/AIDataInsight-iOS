import { describe, expect, it } from 'vitest';
import { normalizeOAuthSession } from './account-mappers';

describe('normalizeOAuthSession', () => {
  it('normalizes snake_case login token fields into AccountSession', () => {
    const session = normalizeOAuthSession({
      access_token: 'access-token',
      refresh_token: 'refresh-token',
      org_id: 7,
    });

    expect(session).toEqual({
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
      orgId: 7,
      username: null,
      isLogin: true,
    });
  });

  it('keeps the previous refresh token when refresh response only returns accessToken', () => {
    const session = normalizeOAuthSession(
      { accessToken: 'new-access' },
      {
        accessToken: 'old-access',
        refreshToken: 'old-refresh',
        orgId: 3,
        username: 'demo',
        isLogin: true,
      },
    );

    expect(session.accessToken).toBe('new-access');
    expect(session.refreshToken).toBe('old-refresh');
    expect(session.orgId).toBe(3);
    expect(session.isLogin).toBe(true);
  });
});
