import { AccountSession } from '../model/ContractModelExports'
import { CommonRequester, HttpMethod } from '../network/CommonRequester'
import { AccountSessionStore, shouldAutoLogin } from './AccountSessionStore'

export interface LoginRequest {
  username: string
  password: string
}

class LoginApiRequest {
  name: string
  pwd: string

  constructor(name: string, pwd: string) {
    this.name = name
    this.pwd = pwd
  }
}

interface LoginPayload {
  accessToken?: string | null
  refreshToken?: string | null
  access_token?: string | null
  refresh_token?: string | null
  orgId?: number | null
  username?: string | null
}

export class AccountAuthService {
  private requester: CommonRequester
  private sessionStore: AccountSessionStore

  constructor(requester: CommonRequester, sessionStore: AccountSessionStore) {
    this.requester = requester
    this.sessionStore = sessionStore
  }

  async login(request: LoginRequest): Promise<AccountSession> {
    let payload = await this.requester.request<LoginPayload>({
      path: '/oauth2/login',
      method: HttpMethod.Post,
      body: new LoginApiRequest(request.username, request.password)
    })

    let session: AccountSession = {
      accessToken: payload.accessToken ?? payload.access_token ?? null,
      refreshToken: payload.refreshToken ?? payload.refresh_token ?? null,
      orgId: payload.orgId ?? null,
      username: payload.username ?? request.username,
      isLogin: true
    }

    await this.sessionStore.save(session)
    return session
  }

  async currentSession(): Promise<AccountSession> {
    return this.sessionStore.load()
  }

  async canAutoLogin(): Promise<boolean> {
    return shouldAutoLogin(await this.sessionStore.load())
  }

  async logout(): Promise<void> {
    await this.sessionStore.clear()
  }
}
