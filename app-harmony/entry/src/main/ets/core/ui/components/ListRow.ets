import { AppColors, AppSpacing, AppTypography } from '../theme/AppTheme'

@Component
export struct ListRow {
  rowTitle: string = ''
  rowSubtitle: string = ''
  tapAction: () => void = () => {}

  build() {
    Row() {
      Column() {
        Text(this.rowTitle)
          .fontSize(AppTypography.body)
          .fontColor(AppColors.textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        if (this.rowSubtitle.length > 0) {
          Text(this.rowSubtitle)
            .fontSize(AppTypography.footnote)
            .fontColor(AppColors.textSecondary)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top: 4 })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text('›')
        .fontSize(22)
        .fontColor(AppColors.textSecondary)
    }
    .width('100%')
    .minHeight(AppSpacing.listRowMinHeight)
    .padding({ top: 10, bottom: 10 })
    .border({ width: { bottom: 1 }, color: AppColors.divider })
    .onClick(this.tapAction)
  }
}
