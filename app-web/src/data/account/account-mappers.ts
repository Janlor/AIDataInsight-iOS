import type { AccountSession, AccountUser } from '@/contracts/generated/models';
import type { OAuthDto } from './account-types';

export function normalizeOAuthSession(
  dto: OAuthDto | null | undefined,
  previous?: AccountSession | null,
): AccountSession {
  const accessToken = normalizeText(dto?.accessToken ?? dto?.access_token) ?? previous?.accessToken ?? null;
  const refreshToken =
    normalizeText(dto?.refreshToken ?? dto?.refresh_token) ?? previous?.refreshToken ?? null;
  const orgId = dto?.orgId ?? dto?.org_id ?? previous?.orgId ?? null;

  return {
    accessToken,
    refreshToken,
    orgId,
    username: previous?.username ?? null,
    isLogin: Boolean(accessToken),
  };
}

export function mergeUserIntoSession(
  session: AccountSession,
  user: AccountUser | null,
): AccountSession {
  return {
    ...session,
    username: user?.username ?? user?.nickname ?? session.username ?? null,
    isLogin: Boolean(session.accessToken),
  };
}

function normalizeText(value: string | null | undefined): string | null {
  const trimmed = value?.trim();
  return trimmed ? trimmed : null;
}
