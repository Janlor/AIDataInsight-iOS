import { common } from '@kit.AbilityKit'
import { preferences } from '@kit.ArkData'
import { AccountUser } from '../model/ContractModelExports'

export interface AccountUserStore {
  load(): Promise<AccountUser | null>
  save(user: AccountUser): Promise<void>
  clear(): Promise<void>
}

export class MemoryAccountUserStore implements AccountUserStore {
  private user: AccountUser | null

  constructor(initialUser: AccountUser | null = null) {
    this.user = initialUser
  }

  async load(): Promise<AccountUser | null> {
    return this.user
  }

  async save(user: AccountUser): Promise<void> {
    this.user = user
  }

  async clear(): Promise<void> {
    this.user = null
  }
}

export class PreferencesAccountUserStore implements AccountUserStore {
  private context: common.UIAbilityContext | null = null
  private cachedPreferences: preferences.Preferences | null = null

  configure(context: common.UIAbilityContext): void {
    this.context = context
    this.cachedPreferences = null
  }

  async load(): Promise<AccountUser | null> {
    try {
      let storage = this.preferences()
      let hasUser = storage.getSync('hasUser', false) as boolean
      if (!hasUser) {
        return null
      }
      return {
        id: this.optionalNumber(storage.getSync('id', -1)),
        username: this.optionalString(storage.getSync('username', '')),
        nickname: this.optionalString(storage.getSync('nickname', '')),
        phone: this.optionalString(storage.getSync('phone', ''))
      }
    } catch (error) {
      return null
    }
  }

  async save(user: AccountUser): Promise<void> {
    try {
      let storage = this.preferences()
      storage.putSync('hasUser', true)
      storage.putSync('id', user.id ?? -1)
      storage.putSync('username', user.username ?? '')
      storage.putSync('nickname', user.nickname ?? '')
      storage.putSync('phone', user.phone ?? '')
      storage.flushSync()
    } catch (error) {
      throw new Error(`保存用户信息失败: ${JSON.stringify(error)}`)
    }
  }

  async clear(): Promise<void> {
    try {
      let storage = this.preferences()
      storage.clearSync()
      storage.flushSync()
    } catch (error) {
      throw new Error(`清除用户信息失败: ${JSON.stringify(error)}`)
    }
  }

  private preferences(): preferences.Preferences {
    if (this.cachedPreferences !== null) {
      return this.cachedPreferences
    }
    if (this.context === null) {
      throw new Error('PreferencesAccountUserStore must be configured before use.')
    }
    try {
      this.cachedPreferences = preferences.getPreferencesSync(this.context, { name: 'account_user' })
    } catch (error) {
      throw new Error(`读取用户信息存储失败: ${JSON.stringify(error)}`)
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
