import { AccountSession, SettingSnapshot } from '../../../core/model/ContractModelExports'

export function buildSettingSnapshot(session: AccountSession): SettingSnapshot {
  return {
    accountInfo: {
      nickname: session.username ?? null,
      username: session.username ?? null,
      phone: null
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
