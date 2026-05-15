import { AIDataInsightGradientBackground } from '../../../core/ui/components/AIDataInsightGradientBackground'
import { AppColors, AppTypography } from '../../../core/ui/theme/AppTheme'
import { privacyPolicySections, privacyPolicyTitle } from '../application/PrivacyContent'

@Component
export struct PrivacyPage {
  onBack: () => void = () => {}

  build() {
    Stack() {
      AIDataInsightGradientBackground()

      Column() {
        Row() {
          Text('返回')
            .fontSize(15)
            .fontColor(AppColors.accent)
            .onClick(this.onBack)

          Text(privacyPolicyTitle)
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

        Scroll() {
          Column() {
            ForEach(privacyPolicySections, (section: string) => {
              Text(section)
                .fontSize(AppTypography.body)
                .fontColor(AppColors.textPrimary)
                .lineHeight(24)
                .width('100%')
                .margin({ bottom: 16 })
            })
          }
          .width('100%')
          .padding({ top: 28, bottom: 24 })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .padding({ left: 24, right: 24, top: 44, bottom: 34 })
    }
    .width('100%')
    .height('100%')
  }
}
