import { AccountSession } from '../model/ContractModelExports'

export const emptyAccountSession: AccountSession = {
  accessToken: null,
  refreshToken: null,
  orgId: null,
  username: null,
  isLogin: false
}

export interface AccountSessionStore {
  load(): Promise<AccountSession>
  save(session: AccountSession): Promise<void>
  clear(): Promise<void>
}

export class MemoryAccountSessionStore implements AccountSessionStore {
  private session: AccountSession

  constructor(initialSession: AccountSession = emptyAccountSession) {
    this.session = initialSession
  }

  async load(): Promise<AccountSession> {
    return this.session
  }

  async save(session: AccountSession): Promise<void> {
    this.session = session
  }

  async clear(): Promise<void> {
    this.session = emptyAccountSession
  }
}

export function shouldAutoLogin(session: AccountSession): boolean {
  return session.isLogin === true && hasText(session.accessToken)
}

function hasText(value?: string | null): boolean {
  return value !== null && value !== undefined && value.length > 0
}
