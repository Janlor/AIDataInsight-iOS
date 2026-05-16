import { accountAuthService } from '../../../app/services/AppServices'
import { AppColors, AppRadius, AppTypography } from '../../../core/ui/theme/AppTheme'
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
  @State pageWidth: number = 0
  @State pageHeight: number = 0

  build() {
    Scroll() {
      if (this.isLandscapeLayout()) {
        this.landscapeContent()
      } else {
        this.portraitContent()
      }
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .onAreaChange((oldArea: Area, newArea: Area) => {
      this.pageWidth = this.areaNumber(newArea.width)
      this.pageHeight = this.areaNumber(newArea.height)
    })
  }

  @Builder
  private portraitContent() {
    Column() {
      Blank()
        .height(60)

      this.brandHeader(true)

      Blank()
        .height(105)

      Column() {
        this.loginForm()
      }
      .width('100%')
        .constraintSize({ maxWidth: 390 })

      Blank()
        .layoutWeight(1)
        .constraintSize({ minHeight: 24 })

      Column() {
        this.privacyAgreement()
      }
      .width('100%')
        .margin({ bottom: 12 })
    }
    .width('100%')
    .constraintSize({ minHeight: '100%' })
    .alignItems(HorizontalAlign.Center)
    .padding({ left: 38, right: 38 })
  }

  @Builder
  private landscapeContent() {
    Column() {
      Row() {
        Column() {
          this.brandHeader(false)
        }
        .layoutWeight(9)
        .margin({ right: 56 })

        Column() {
          this.loginForm()

          Blank()
            .height(28)

          this.privacyAgreement()
        }
        .layoutWeight(10)
        .constraintSize({ maxWidth: 390 })
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .constraintSize({ maxWidth: 820 })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .constraintSize({ minHeight: '100%' })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding({ left: 40, right: 40, top: 24, bottom: 24 })
  }

  @Builder
  private brandHeader(centered: boolean) {
    Column() {
      Image($r('app.media.ic_login_app'))
        .width(centered ? 86 : 72)
        .height(centered ? 86 : 72)
        .objectFit(ImageFit.Cover)
        .borderRadius(centered ? 19 : 16)
        .backgroundColor('#F2F5FA')

      Text('AI数据分析助手')
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppColors.textPrimary)
        .textAlign(centered ? TextAlign.Center : TextAlign.Start)
        .width('100%')
        .margin({ top: 30 })

      Text('让工作更流畅更轻松')
        .fontSize(AppTypography.body)
        .fontColor(AppColors.textSecondary)
        .textAlign(centered ? TextAlign.Center : TextAlign.Start)
        .width('100%')
        .margin({ top: 10 })
    }
    .width('100%')
    .alignItems(centered ? HorizontalAlign.Center : HorizontalAlign.Start)
  }

  @Builder
  private loginForm() {
    Column() {
      this.underlinedField('请输入账号', this.username, false, !this.isLoading, (value: string) => {
        this.username = limitText(value, maxLoginUsernameLength)
        this.errorMessage = null
      })

      Blank()
        .height(20)

      this.underlinedField('请输入密码', this.password, true, !this.isLoading, (value: string) => {
        this.password = limitText(value, maxLoginPasswordLength)
        this.errorMessage = null
      })

      Blank()
        .height(30)

      this.loginButton()

      if (this.errorMessage !== null) {
        Text(this.errorMessage ?? '')
          .fontSize(AppTypography.footnote)
          .fontColor('#FFFFFF')
          .width('100%')
          .padding({ left: 14, right: 14, top: 10, bottom: 10 })
          .backgroundColor('#E5484D')
          .borderRadius(AppRadius.panel)
          .margin({ top: 12 })
      }
    }
    .width('100%')
  }

  @Builder
  private underlinedField(
    placeholder: string,
    value: string,
    isPassword: boolean,
    enabled: boolean,
    changeAction: (value: string) => void
  ) {
    Column() {
      TextInput({ placeholder: placeholder, text: value })
        .width('100%')
        .height(45)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppColors.textPrimary)
        .placeholderColor('#A8B1C0')
        .backgroundColor(Color.Transparent)
        .padding({ left: 0, right: 0 })
        .enabled(enabled)
        .type(isPassword ? InputType.Password : InputType.Normal)
        .onChange(changeAction)

      Row()
        .width('100%')
        .height(1)
        .backgroundColor('#DCE3EE')
    }
    .width('100%')
  }

  @Builder
  private loginButton() {
    Button(this.isLoading ? '登录中…' : '登录')
      .width('100%')
      .height(52)
      .fontSize(17)
      .fontWeight(FontWeight.Medium)
      .fontColor('#FFFFFF')
      .backgroundColor(this.currentCanLogin() ? AppColors.accent : '#C7D1DF')
      .borderRadius(12)
      .enabled(this.currentCanLogin())
      .onClick(() => {
        this.submitLogin()
      })
  }

  @Builder
  private privacyAgreement() {
    Row() {
      Image(this.isPrivacyAccepted ? $r('app.media.ic_checkbox_selected') : $r('app.media.ic_checkbox_normal'))
        .width(18)
        .height(18)
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
    .width('100%')
    .constraintSize({ maxWidth: 320 })
    .height(44)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
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

  private isLandscapeLayout(): boolean {
    return this.pageWidth > this.pageHeight && this.pageWidth >= 600
  }

  private areaNumber(value: number | string | Resource): number {
    if (typeof value === 'number') {
      return value
    }
    if (typeof value === 'string') {
      let parsed = Number(value)
      return isNaN(parsed) ? 0 : parsed
    }
    return 0
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
