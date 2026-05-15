import { describe, it, expect } from '@ohos/hypium'
import {
  buildLoginUiState,
  canLogin,
  limitText,
  validateLoginInput
} from '../main/ets/feature/login/application/LoginState'

export default function loginStateTest() {
  describe('loginStateTest', () => {
    it('requires username and password before login', 0, () => {
      expect(canLogin('', 'pwd', false)).assertFalse()
      expect(canLogin('demo', '', false)).assertFalse()
      expect(canLogin('demo', 'pwd', true)).assertFalse()
      expect(canLogin('demo', 'pwd', false)).assertTrue()
    })

    it('validates privacy agreement before submit', 0, () => {
      let state = buildLoginUiState('demo', 'demo@123', false, false, null)

      expect(validateLoginInput(state)).assertEqual('请先阅读并同意《隐私政策》')
    })

    it('limits username and password text', 0, () => {
      expect(limitText('123456', 3)).assertEqual('123')
      expect(limitText('123', 3)).assertEqual('123')
    })
  })
}
