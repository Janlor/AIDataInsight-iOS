export interface LoginUiState {
  username: string
  password: string
  isPrivacyAccepted: boolean
  isLoading: boolean
  errorMessage?: string | null
  canLogin: boolean
}

export const defaultLoginUsername = 'demo'
export const defaultLoginPassword = 'demo@123'
export const maxLoginUsernameLength = 30
export const maxLoginPasswordLength = 30

export function buildLoginUiState(
  username: string,
  password: string,
  isPrivacyAccepted: boolean,
  isLoading: boolean,
  errorMessage?: string | null
): LoginUiState {
  return {
    username: limitText(username, maxLoginUsernameLength),
    password: limitText(password, maxLoginPasswordLength),
    isPrivacyAccepted: isPrivacyAccepted,
    isLoading: isLoading,
    errorMessage: errorMessage ?? null,
    canLogin: canLogin(username, password, isLoading)
  }
}

export function canLogin(username: string, password: string, isLoading: boolean): boolean {
  return hasText(username) && hasText(password) && !isLoading
}

export function validateLoginInput(state: LoginUiState): string | null {
  if (!hasText(state.username)) {
    return '请输入账号'
  }
  if (!hasText(state.password)) {
    return '请输入密码'
  }
  if (!state.isPrivacyAccepted) {
    return '请先阅读并同意《隐私政策》'
  }
  return null
}

export function limitText(value: string, maxLength: number): string {
  if (value.length <= maxLength) {
    return value
  }
  return value.substring(0, maxLength)
}

function hasText(value: string): boolean {
  return value.trim().length > 0
}
