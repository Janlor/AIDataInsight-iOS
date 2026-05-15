import { AppColors, AppRadius, AppSpacing, AppTypography } from '../theme/AppTheme'

@Component
export struct PrimaryButton {
  buttonText: string = ''
  isEnabled: boolean = true
  tapAction: () => void = () => {}

  build() {
    Button(this.buttonText)
      .width('100%')
      .height(AppSpacing.controlHeight)
      .borderRadius(AppRadius.control)
      .fontSize(AppTypography.body)
      .fontColor('#FFFFFF')
      .backgroundColor(this.isEnabled ? AppColors.accent : '#B7C6D9')
      .enabled(this.isEnabled)
      .onClick(this.tapAction)
  }
}
