import type { AccountSession, AccountUser } from '@/contracts/generated/models';

export interface LoginInput {
  name: string;
  pwd: string;
}

export interface OAuthDto {
  accessToken?: string | null;
  refreshToken?: string | null;
  orgId?: number | null;
  access_token?: string | null;
  refresh_token?: string | null;
  org_id?: number | null;
}

export interface AccountState {
  session: AccountSession;
  user: AccountUser | null;
}

export const emptySession: AccountSession = {
  accessToken: null,
  refreshToken: null,
  orgId: null,
  username: null,
  isLogin: false,
};
