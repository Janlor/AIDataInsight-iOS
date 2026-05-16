import { common } from '@kit.AbilityKit'
import { preferences } from '@kit.ArkData'
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

export class PreferencesAccountSessionStore implements AccountSessionStore {
  private context: common.UIAbilityContext | null = null
  private cachedPreferences: preferences.Preferences | null = null

  configure(context: common.UIAbilityContext): void {
    this.context = context
    this.cachedPreferences = null
  }

  async load(): Promise<AccountSession> {
    try {
      let storage = this.preferences()
      return {
        accessToken: this.optionalString(storage.getSync('accessToken', '')),
        refreshToken: this.optionalString(storage.getSync('refreshToken', '')),
        orgId: this.optionalNumber(storage.getSync('orgId', -1)),
        username: this.optionalString(storage.getSync('username', '')),
        isLogin: storage.getSync('isLogin', false) as boolean
      }
    } catch (error) {
      return emptyAccountSession
    }
  }

  async save(session: AccountSession): Promise<void> {
    try {
      let storage = this.preferences()
      storage.putSync('accessToken', session.accessToken ?? '')
      storage.putSync('refreshToken', session.refreshToken ?? '')
      storage.putSync('orgId', session.orgId ?? -1)
      storage.putSync('username', session.username ?? '')
      storage.putSync('isLogin', session.isLogin)
      storage.flushSync()
    } catch (error) {
      throw new Error(`保存登录态失败: ${JSON.stringify(error)}`)
    }
  }

  async clear(): Promise<void> {
    try {
      let storage = this.preferences()
      storage.clearSync()
      storage.flushSync()
    } catch (error) {
      throw new Error(`清除登录态失败: ${JSON.stringify(error)}`)
    }
  }

  private preferences(): preferences.Preferences {
    if (this.cachedPreferences !== null) {
      return this.cachedPreferences
    }
    if (this.context === null) {
      throw new Error('PreferencesAccountSessionStore must be configured before use.')
    }
    try {
      this.cachedPreferences = preferences.getPreferencesSync(this.context, { name: 'account_session' })
    } catch (error) {
      throw new Error(`读取登录态存储失败: ${JSON.stringify(error)}`)
    }
    return this.cachedPreferences
  }

  private optionalString(value: preferences.ValueType): string | null {
    if (typeof value !== 'string' || value.length === 0) {
      return null
    }
    return value
  }

  private optionalNumber(value: preferences.ValueType): number | null {
    if (typeof value !== 'number' || value < 0) {
      return null
    }
    return value
  }
}

export function shouldAutoLogin(session: AccountSession): boolean {
  return session.isLogin === true && hasText(session.accessToken)
}

function hasText(value?: string | null): boolean {
  return value !== null && value !== undefined && value.length > 0
}
