import { AppColors } from '../theme/AppTheme'

@Component
export struct AIDataInsightGradientBackground {
  build() {
    Column()
      .width('100%')
      .height('100%')
      .linearGradient({
        angle: 180,
        colors: [
          [AppColors.brandStart, 0.0],
          [AppColors.brandEnd, 1.0]
        ]
      })
  }
}
