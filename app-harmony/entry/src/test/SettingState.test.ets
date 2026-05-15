import { describe, it, expect } from '@ohos/hypium'
import { AccountSession } from '../main/ets/core/model/ContractModelExports'
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
      let snapshot = buildSettingSnapshot(session)

      expect(snapshot.accountInfo.username).assertEqual('demo')
      expect(snapshot.accountInfo.nickname).assertEqual('demo')
      expect(snapshot.capability.canOpenPrivacy).assertTrue()
      expect(snapshot.capability.canLogout).assertTrue()
      expect(snapshot.appVersion).assertEqual('1.0.0')
    })

    it('uses unset text for empty account fields', 0, () => {
      expect(displaySettingText(null)).assertEqual('未设置')
      expect(displaySettingText('')).assertEqual('未设置')
      expect(displaySettingText('demo')).assertEqual('demo')
    })
  })
}
