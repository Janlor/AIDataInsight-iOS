import { AccountAuthService } from '../../core/account/AccountAuthService'
import { common } from '@kit.AbilityKit'
import { PreferencesAccountSessionStore } from '../../core/account/AccountSessionStore'
import { CommonRequester } from '../../core/network/CommonRequester'
import { HarmonyHttpTransport } from '../../core/network/HarmonyHttpTransport'

export const appSessionStore = new PreferencesAccountSessionStore()
export const appHttpTransport = new HarmonyHttpTransport()
export const appRequester = new CommonRequester(appHttpTransport)
export const accountAuthService = new AccountAuthService(appRequester, appSessionStore)

export function configureAppServices(context: common.UIAbilityContext): void {
  appSessionStore.configure(context)
}
