import { AccountAuthService } from '../../core/account/AccountAuthService'
import { MemoryAccountSessionStore } from '../../core/account/AccountSessionStore'
import { CommonRequester } from '../../core/network/CommonRequester'
import { MockHttpTransport } from '../../core/network/MockHttpTransport'

const mockResponses = new Map<string, string>()
mockResponses.set(
  '/oauth2/login',
  '{"code":200,"msg":"ok","data":{"access_token":"mock-access-token","refresh_token":"mock-refresh-token","orgId":1},"trace":null,"tid":null}'
)

export const appSessionStore = new MemoryAccountSessionStore()
export const appHttpTransport = new MockHttpTransport(mockResponses)
export const appRequester = new CommonRequester(appHttpTransport)
export const accountAuthService = new AccountAuthService(appRequester, appSessionStore)
