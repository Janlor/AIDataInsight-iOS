export interface AppColorTokens {
  brandStart: string
  brandEnd: string
  accent: string
  textPrimary: string
  textSecondary: string
  divider: string
  surface: string
  danger: string
}

export interface AppSpacingTokens {
  pageHorizontal: number
  pageVertical: number
  itemGap: number
  controlHeight: number
  listRowMinHeight: number
}

export interface AppRadiusTokens {
  control: number
  panel: number
}

export interface AppTypographyTokens {
  title: number
  subtitle: number
  body: number
  footnote: number
}

export const AppColors: AppColorTokens = {
  brandStart: '#EAF6FF',
  brandEnd: '#F8FBFF',
  accent: '#1677FF',
  textPrimary: '#17233D',
  textSecondary: '#6B778C',
  divider: '#E6EAF0',
  surface: '#FFFFFF',
  danger: '#E5484D'
}

export const AppSpacing: AppSpacingTokens = {
  pageHorizontal: 24,
  pageVertical: 20,
  itemGap: 12,
  controlHeight: 48,
  listRowMinHeight: 56
}

export const AppRadius: AppRadiusTokens = {
  control: 8,
  panel: 8
}

export const AppTypography: AppTypographyTokens = {
  title: 24,
  subtitle: 16,
  body: 15,
  footnote: 13
}
