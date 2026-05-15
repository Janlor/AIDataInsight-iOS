import { AIChatPage } from '../../feature/ai_chat/pages/AIChatPage'
import { HistoryPage } from '../../feature/history/pages/HistoryPage'
import { AppColors, AppSpacing, AppTypography } from '../../core/ui/theme/AppTheme'

@Component
export struct AIHomePage {
  onOpenSettings: () => void = () => {}

  @State isHistoryOpen: boolean = false
  @State selectedHistoryId: number | null = null
  @State conversationVersion: number = 0

  build() {
    Stack({ alignContent: Alignment.Start }) {
      Column() {
        this.navigationBar()

        AIChatPage({
          selectedHistoryId: this.selectedHistoryId,
          conversationVersion: this.conversationVersion
        })
          .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .padding({ left: 16, right: 16, top: 44, bottom: 18 })

      if (this.isHistoryOpen) {
        Row()
          .width('100%')
          .height('100%')
          .backgroundColor('#66000000')
          .onClick(() => {
            this.isHistoryOpen = false
          })

        Row() {
          HistoryPage({
            onClose: () => {
              this.isHistoryOpen = false
            },
            onOpenSettings: () => {
              this.isHistoryOpen = false
              this.onOpenSettings()
            },
            onSelectHistory: (historyId: number) => {
              this.selectedHistoryId = historyId
              this.isHistoryOpen = false
            }
          })
        }
        .width('86%')
        .height('100%')
        .backgroundColor('#F6FAFF')
        .shadow({ radius: 18, color: '#33000000', offsetX: 4, offsetY: 0 })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private navigationBar() {
    Row() {
      Text('历史')
        .fontSize(AppTypography.body)
        .fontColor(AppColors.accent)
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .onClick(() => {
          this.isHistoryOpen = true
        })

      Column() {
        Text('AI数据分析助手')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.textPrimary)
        Text('经营数据分析')
          .fontSize(12)
          .fontColor(AppColors.textSecondary)
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Center)
      .layoutWeight(1)

      Text('新会话')
        .fontSize(AppTypography.body)
        .fontColor(AppColors.accent)
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .onClick(() => {
          this.selectedHistoryId = null
          this.conversationVersion += 1
        })
    }
    .width('100%')
    .height(56)
    .alignItems(VerticalAlign.Center)
    .margin({ bottom: AppSpacing.itemGap })
  }
}
