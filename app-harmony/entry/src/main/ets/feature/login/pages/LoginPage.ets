import { accountAuthService } from '../../../app/services/AppServices'
import { PrimaryButton } from '../../../core/ui/components/PrimaryButton'
import { AppColors, AppSpacing, AppTypography } from '../../../core/ui/theme/AppTheme'
import {
  buildLoginUiState,
  defaultLoginPassword,
  defaultLoginUsername,
  limitText,
  maxLoginPasswordLength,
  maxLoginUsernameLength,
  validateLoginInput
} from '../application/LoginState'

@Component
export struct LoginPage {
  onLoginSucceeded: () => void = () => {}
  onOpenPrivacy: () => void = () => {}

  @State username: string = defaultLoginUsername
  @State password: string = defaultLoginPassword
  @State isPrivacyAccepted: boolean = true
  @State isLoading: boolean = false
  @State errorMessage: string | null = null

  build() {
    Column() {
      Blank()

      Column() {
        Image($r('app.media.ic_login_app'))
          .width(86)
          .height(86)
          .objectFit(ImageFit.Contain)
          .borderRadius(19)
          .margin({ bottom: 18 })

        Text('AI数据分析助手')
          .fontSize(AppTypography.title)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.textPrimary)

        Text('让工作更流畅更轻松')
          .fontSize(AppTypography.subtitle)
          .fontColor(AppColors.textSecondary)
          .margin({ top: 8 })
      }
      .alignItems(HorizontalAlign.Center)

      Column() {
        TextInput({ placeholder: '请输入账号', text: this.username })
          .height(AppSpacing.controlHeight)
          .backgroundColor(AppColors.surface)
          .borderRadius(8)
          .enabled(!this.isLoading)
          .onChange((value: string) => {
            this.username = limitText(value, maxLoginUsernameLength)
            this.errorMessage = null
          })

        TextInput({ placeholder: '请输入密码', text: this.password })
          .height(AppSpacing.controlHeight)
          .backgroundColor(AppColors.surface)
          .borderRadius(8)
          .enabled(!this.isLoading)
          .margin({ top: AppSpacing.itemGap })
          .onChange((value: string) => {
            this.password = limitText(value, maxLoginPasswordLength)
            this.errorMessage = null
          })

        if (this.errorMessage !== null) {
          Text(this.errorMessage)
            .fontSize(AppTypography.footnote)
            .fontColor(AppColors.danger)
            .width('100%')
            .margin({ top: 10 })
        }

        PrimaryButton({
          buttonText: this.isLoading ? '登录中...' : '登录',
          isEnabled: this.currentCanLogin(),
          tapAction: () => {
            this.submitLogin()
          }
        })
          .margin({ top: 22 })
      }
      .width('100%')
      .margin({ top: 42 })

      Blank()

      Row() {
        Image(this.isPrivacyAccepted ? $r('app.media.ic_checkbox_selected') : $r('app.media.ic_checkbox_normal'))
          .width(21)
          .height(21)
          .objectFit(ImageFit.Contain)
          .onClick(() => {
            this.isPrivacyAccepted = !this.isPrivacyAccepted
            this.errorMessage = null
          })

        Text('已阅读并同意')
          .fontSize(AppTypography.footnote)
          .fontColor(AppColors.textSecondary)
          .margin({ left: 8 })

        Text('《隐私政策》')
          .fontSize(AppTypography.footnote)
          .fontColor(AppColors.accent)
          .onClick(this.onOpenPrivacy)
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .padding({
      left: AppSpacing.pageHorizontal,
      right: AppSpacing.pageHorizontal,
      top: 44,
      bottom: 34
    })
  }

  private currentCanLogin(): boolean {
    return buildLoginUiState(
      this.username,
      this.password,
      this.isPrivacyAccepted,
      this.isLoading,
      this.errorMessage
    ).canLogin
  }

  private async submitLogin(): Promise<void> {
    let state = buildLoginUiState(
      this.username,
      this.password,
      this.isPrivacyAccepted,
      this.isLoading,
      this.errorMessage
    )
    let validationMessage = validateLoginInput(state)
    if (validationMessage !== null) {
      this.errorMessage = validationMessage
      return
    }

    this.isLoading = true
    this.errorMessage = null
    try {
      await accountAuthService.login({
        username: this.username,
        password: this.password
      })
      this.onLoginSucceeded()
    } catch (error) {
      this.errorMessage = `登录失败：${JSON.stringify(error)}`
    }
    this.isLoading = false
  }
}
