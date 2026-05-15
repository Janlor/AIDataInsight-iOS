import { describe, it, expect } from '@ohos/hypium'
import { MemoryAccountSessionStore, shouldAutoLogin } from '../../main/ets/core/account/AccountSessionStore'
import { AccountAuthService } from '../../main/ets/core/account/AccountAuthService'
import { ApiErrorKind, apiErrorFromCode } from '../../main/ets/core/network/ApiError'
import { ApiEnvironmentProvider } from '../../main/ets/core/network/ApiEnvironmentProvider'
import { CommonRequester, HttpMethod } from '../../main/ets/core/network/CommonRequester'
import { MockHttpTransport } from '../../main/ets/core/network/MockHttpTransport'

export default function coreFoundationTest() {
  describe('coreFoundationTest', () => {
    it('resolves relative path with mock base url', 0, () => {
      let provider = new ApiEnvironmentProvider({
        name: 'mock',
        baseUrl: 'https://example.com/mock',
        description: null
      })

      expect(provider.resolve('/chat/template')).assertEqual('https://example.com/mock/chat/template')
      expect(provider.resolve('login')).assertEqual('https://example.com/mock/login')
      expect(provider.endpoints().streamPath).assertEqual('/stream')
    })

    it('maps api status codes to session errors', 0, () => {
      expect(apiErrorFromCode(200)).assertEqual(null)
      expect(apiErrorFromCode(401)?.kind).assertEqual(ApiErrorKind.Unauthorized)
      expect(apiErrorFromCode(402)?.kind).assertEqual(ApiErrorKind.TokenExpired)
      expect(apiErrorFromCode(500, 'server')?.kind).assertEqual(ApiErrorKind.Server)
    })

    it('requests data from mock transport envelope', 0, async () => {
      let transport = new MockHttpTransport({
        '/chat/template': '{"code":200,"msg":"OK","data":{"questions":["A","B"]}}'
      })
      let requester = new CommonRequester(transport)
      let data = await requester.request<QuestionData>({
        path: '/chat/template',
        method: HttpMethod.Get
      })

      expect(data.questions.length).assertEqual(2)
      expect(data.questions[0]).assertEqual('A')
    })

    it('checks auto login from stored session', 0, async () => {
      let store = new MemoryAccountSessionStore()
      expect(shouldAutoLogin(await store.load())).assertFalse()

      await store.save({
        accessToken: 'token',
        refreshToken: 'refresh',
        orgId: null,
        username: 'janlor',
        isLogin: true
      })

      expect(shouldAutoLogin(await store.load())).assertTrue()
    })

    it('login saves normalized session', 0, async () => {
      let transport = new MockHttpTransport({
        '/login': '{"code":200,"msg":"ok","data":{"access_token":"access-token","refresh_token":"refresh-token"}}'
      })
      let requester = new CommonRequester(transport)
      let store = new MemoryAccountSessionStore()
      let service = new AccountAuthService(requester, store)

      let session = await service.login({
        username: 'janlor',
        password: 'password'
      })

      expect(session.accessToken).assertEqual('access-token')
      expect(session.refreshToken).assertEqual('refresh-token')
      expect(session.username).assertEqual('janlor')
      expect(await service.canAutoLogin()).assertTrue()

      await service.logout()
      expect(await service.canAutoLogin()).assertFalse()
    })
  })
}

interface QuestionData {
  questions: Array<string>
}
