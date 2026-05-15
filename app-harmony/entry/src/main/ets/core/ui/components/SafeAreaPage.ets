import { AppSpacing } from '../theme/AppTheme'

@Component
export struct SafeAreaPage {
  @BuilderParam content: () => void

  build() {
    Column() {
      this.content()
    }
    .width('100%')
    .height('100%')
    .padding({
      left: AppSpacing.pageHorizontal,
      right: AppSpacing.pageHorizontal,
      top: AppSpacing.pageVertical,
      bottom: AppSpacing.pageVertical
    })
  }
}
