import { AccountSession, AccountUser } from '../model/ContractModelExports'
import { ApiError, ApiErrorKind } from '../network/ApiError'
import { CommonRequester, HttpMethod } from '../network/CommonRequester'
import { AccountSessionStore, shouldAutoLogin } from './AccountSessionStore'
import { AccountUserStore } from './AccountUserStore'

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
  private userStore: AccountUserStore

  constructor(requester: CommonRequester, sessionStore: AccountSessionStore, userStore: AccountUserStore) {
    this.requester = requester
    this.sessionStore = sessionStore
    this.userStore = userStore
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

    await this.userStore.clear()
    await this.sessionStore.save(session)
    await this.refreshUserInfoSilently()
    return session
  }

  async currentSession(): Promise<AccountSession> {
    return this.sessionStore.load()
  }

  async currentUser(): Promise<AccountUser | null> {
    return this.userStore.load()
  }

  async getUserInfo(): Promise<AccountUser> {
    try {
      let user = await this.requester.request<AccountUser>({
        path: '/oauth2/getUserInfo',
        method: HttpMethod.Get,
        headers: await this.authHeaders()
      })
      await this.userStore.save(user)
      return user
    } catch (error) {
      if (error instanceof ApiError &&
        (error.kind === ApiErrorKind.Unauthorized || error.kind === ApiErrorKind.TokenExpired)) {
        await this.clearProtectedAccountState()
      }
      throw this.normalizedError(error)
    }
  }

  async refreshUserInfoSilently(): Promise<void> {
    try {
      await this.getUserInfo()
    } catch (error) {
    }
  }

  async canAutoLogin(): Promise<boolean> {
    return shouldAutoLogin(await this.sessionStore.load())
  }

  async logout(): Promise<void> {
    await this.clearProtectedAccountState()
  }

  async clearProtectedAccountState(): Promise<void> {
    await this.sessionStore.clear()
    await this.userStore.clear()
  }

  private async authHeaders(): Promise<Map<string, string>> {
    let session = await this.sessionStore.load()
    let headers = new Map<string, string>()
    if (session.accessToken !== null && session.accessToken !== undefined && session.accessToken.length > 0) {
      headers.set('Authorization', `Bearer ${session.accessToken}`)
    }
    return headers
  }

  private normalizedError(error: Object): Error {
    if (error instanceof Error) {
      return error
    }
    return new Error(JSON.stringify(error))
  }
}
