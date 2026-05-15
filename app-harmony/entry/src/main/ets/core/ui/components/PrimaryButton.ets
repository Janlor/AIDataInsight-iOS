import { AppColors, AppRadius, AppSpacing, AppTypography } from '../theme/AppTheme'

@Component
export struct PrimaryButton {
  text: string
  enabled: boolean = true
  onClick: () => void = () => {}

  build() {
    Button(this.text)
      .width('100%')
      .height(AppSpacing.controlHeight)
      .borderRadius(AppRadius.control)
      .fontSize(AppTypography.body)
      .fontColor('#FFFFFF')
      .backgroundColor(this.enabled ? AppColors.accent : '#B7C6D9')
      .enabled(this.enabled)
      .onClick(this.onClick)
  }
}
