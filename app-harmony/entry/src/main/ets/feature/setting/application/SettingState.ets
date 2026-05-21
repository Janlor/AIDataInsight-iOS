import { AccountSession, AccountUser, SettingSnapshot } from '../../../core/model/ContractModelExports'

export function buildSettingSnapshot(session: AccountSession, user: AccountUser | null = null): SettingSnapshot {
  return {
    accountInfo: {
      nickname: user?.nickname ?? null,
      username: user?.username ?? session.username ?? null,
      phone: user?.phone ?? null
    },
    capability: {
      canUpdatePassword: false,
      canOpenPrivacy: true,
      canLogout: true
    },
    appVersion: '1.0.0'
  }
}

export function displaySettingText(value?: string | null): string {
  if (value === null || value === undefined || value.length === 0) {
    return '未设置'
  }
  return value
}
