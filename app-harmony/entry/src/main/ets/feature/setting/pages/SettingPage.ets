import { accountAuthService } from '../../../app/services/AppServices'
import { SettingSnapshot } from '../../../core/model/ContractModelExports'
import { AIDataInsightGradientBackground } from '../../../core/ui/components/AIDataInsightGradientBackground'
import { AppColors, AppRadius, AppSpacing, AppTypography } from '../../../core/ui/theme/AppTheme'
import { buildSettingSnapshot, displaySettingText } from '../application/SettingState'

@Component
export struct SettingPage {
  onBack: () => void = () => {}
  onOpenPrivacy: () => void = () => {}
  onLogoutSucceeded: () => void = () => {}

  @State snapshot: SettingSnapshot | null = null
  @State showLogoutConfirm: boolean = false
  @State isLoggingOut: boolean = false

  aboutToAppear() {
    this.loadSnapshot()
  }

  build() {
    Stack() {
      AIDataInsightGradientBackground()

      Column() {
        this.navigationBar()

        if (this.snapshot === null) {
          Text('正在加载设置')
            .fontSize(AppTypography.body)
            .fontColor(AppColors.textSecondary)
            .margin({ top: 80 })
        } else {
          List() {
            ListItem() {
              this.sectionHeader('账户')
            }
            ListItem() {
              this.settingRow('昵称', displaySettingText(this.snapshot.accountInfo.nickname), false, false, () => {})
            }
            ListItem() {
              this.settingRow('登录名', displaySettingText(this.snapshot.accountInfo.username), false, false, () => {})
            }
            ListItem() {
              this.settingRow('手机号', displaySettingText(this.snapshot.accountInfo.phone), false, false, () => {})
            }
            ListItem() {
              this.sectionHeader('关于')
            }
            if (this.snapshot.capability.canOpenPrivacy) {
              ListItem() {
                this.settingRow('隐私政策', '', true, false, this.onOpenPrivacy)
              }
            }
            ListItem() {
              this.settingRow('App版本', this.snapshot.appVersion, false, false, () => {})
            }
            if (this.snapshot.capability.canLogout) {
              ListItem() {
                this.logoutButton()
              }
            }
          }
          .width('100%')
          .layoutWeight(1)
          .edgeEffect(EdgeEffect.None)
        }
      }
      .width('100%')
      .height('100%')
      .padding({ left: 16, right: 16, top: 44, bottom: 34 })

      if (this.showLogoutConfirm) {
        Column() {
          Blank()
          Column() {
            Text('确认注销并退出系统吗？')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(AppColors.textPrimary)

            Row() {
              Text('取消')
                .fontSize(AppTypography.body)
                .fontColor(AppColors.textSecondary)
                .layoutWeight(1)
                .textAlign(TextAlign.Center)
                .padding({ top: 14, bottom: 14 })
                .onClick(() => {
                  this.showLogoutConfirm = false
                })

              Text(this.isLoggingOut ? '退出中...' : '确定')
                .fontSize(AppTypography.body)
                .fontColor(AppColors.danger)
                .layoutWeight(1)
                .textAlign(TextAlign.Center)
                .padding({ top: 14, bottom: 14 })
                .onClick(() => {
                  this.logout()
                })
            }
            .width('100%')
            .margin({ top: 18 })
          }
          .width('86%')
          .padding({ left: 20, right: 20, top: 22, bottom: 10 })
          .backgroundColor(AppColors.surface)
          .borderRadius(AppRadius.panel)
          Blank()
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#66000000')
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private navigationBar() {
    Row() {
      Text('返回')
        .fontSize(15)
        .fontColor(AppColors.accent)
        .onClick(this.onBack)

      Text('设置')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Text(' ')
        .fontSize(15)
        .width(32)
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  private sectionHeader(title: string) {
    Text(title)
      .fontSize(13)
      .fontColor(AppColors.textSecondary)
      .width('100%')
      .margin({ left: 12, top: 18, bottom: 8 })
  }

  @Builder
  private settingRow(title: string, detail: string, selectable: boolean, destructive: boolean, tapAction: () => void) {
    Row() {
      Text(title)
        .fontSize(AppTypography.body)
        .fontColor(destructive ? AppColors.danger : AppColors.textPrimary)
        .layoutWeight(1)

      if (detail.length > 0) {
        Text(detail)
          .fontSize(AppTypography.body)
          .fontColor(AppColors.textSecondary)
          .margin({ right: selectable ? 8 : 0 })
      }

      if (selectable) {
        Text('›')
          .fontSize(22)
          .fontColor(AppColors.textSecondary)
      }
    }
    .width('100%')
    .height(AppSpacing.listRowMinHeight)
    .padding({ left: 16, right: 16, top: 10, bottom: 10 })
    .backgroundColor(AppColors.surface)
    .border({ width: { bottom: 1 }, color: AppColors.divider })
    .onClick(() => {
      if (selectable) {
        tapAction()
      }
    })
  }

  @Builder
  private logoutButton() {
    Text(this.isLoggingOut ? '退出中...' : '退出登录')
      .fontSize(AppTypography.body)
      .fontColor(AppColors.danger)
      .textAlign(TextAlign.Center)
      .width('100%')
      .padding({ top: 16, bottom: 16 })
      .backgroundColor(AppColors.surface)
      .borderRadius(AppRadius.panel)
      .margin({ top: 22 })
      .onClick(() => {
        this.showLogoutConfirm = true
      })
  }

  private async loadSnapshot(): Promise<void> {
    let session = await accountAuthService.currentSession()
    this.snapshot = buildSettingSnapshot(session)
  }

  private async logout(): Promise<void> {
    if (this.isLoggingOut) {
      return
    }
    this.isLoggingOut = true
    await accountAuthService.logout()
    this.showLogoutConfirm = false
    this.isLoggingOut = false
    this.onLogoutSucceeded()
  }
}
