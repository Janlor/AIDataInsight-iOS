import { AppDestination } from './AppDestination'

export interface AppNavigationState {
  current: AppDestination
  selectedHistoryId?: number
}

export function initialNavigationState(isLogin: boolean): AppNavigationState {
  return {
    current: isLogin ? AppDestination.AIHome : AppDestination.Login,
    selectedHistoryId: undefined,
  }
}
