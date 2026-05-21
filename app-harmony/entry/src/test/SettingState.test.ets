import { describe, it, expect } from '@ohos/hypium'
import { AccountSession, AccountUser } from '../main/ets/core/model/ContractModelExports'
import { buildSettingSnapshot, displaySettingText } from '../main/ets/feature/setting/application/SettingState'

export default function settingStateTest() {
  describe('settingStateTest', () => {
    it('builds setting snapshot from account session', 0, () => {
      let session: AccountSession = {
        accessToken: 'token',
        refreshToken: 'refresh',
        orgId: 1,
        username: 'demo',
        isLogin: true
      }
      let user: AccountUser = {
        id: 1,
        username: 'remote-demo',
        nickname: 'Remote Demo',
        phone: '13800000000'
      }
      let snapshot = buildSettingSnapshot(session, user)

      expect(snapshot.accountInfo.username).assertEqual('remote-demo')
      expect(snapshot.accountInfo.nickname).assertEqual('Remote Demo')
      expect(snapshot.accountInfo.phone).assertEqual('13800000000')
      expect(snapshot.capability.canOpenPrivacy).assertTrue()
      expect(snapshot.capability.canLogout).assertTrue()
      expect(snapshot.appVersion).assertEqual('1.0.0')
    })

    it('uses cached session username only when AccountUser is absent', 0, () => {
      let session: AccountSession = {
        accessToken: 'token',
        refreshToken: 'refresh',
        orgId: 1,
        username: 'demo',
        isLogin: true
      }
      let snapshot = buildSettingSnapshot(session, null)

      expect(snapshot.accountInfo.username).assertEqual('demo')
      expect(snapshot.accountInfo.nickname).assertEqual(null)
      expect(snapshot.accountInfo.phone).assertEqual(null)
    })

    it('uses unset text for empty account fields', 0, () => {
      expect(displaySettingText(null)).assertEqual('未设置')
      expect(displaySettingText('')).assertEqual('未设置')
      expect(displaySettingText('demo')).assertEqual('demo')
    })
  })
}
