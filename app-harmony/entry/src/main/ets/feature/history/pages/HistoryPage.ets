import { AppColors, AppRadius, AppTypography } from '../../../core/ui/theme/AppTheme'
import { historyRuntimeStore } from '../application/HistoryRuntime'
import { HistoryItemUiModel, HistorySectionUiModel, HistoryUiState, initialHistoryUiState } from '../application/HistoryState'

@Component
export struct HistoryPage {
  @Prop @Watch('onRefreshVersionChanged') refreshVersion: number = 0

  onClose: () => void = () => {}
  onOpenSettings: () => void = () => {}
  onSelectHistory: (historyId: number) => void = () => {}

  @State uiState: HistoryUiState = initialHistoryUiState()

  aboutToAppear() {
    this.uiState = historyRuntimeStore.snapshot()
    this.refresh()
  }

  private onRefreshVersionChanged(): void {
    this.refresh()
  }

  build() {
    Column() {
      Row() {
        Text(this.uiState.title)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)

        Text('设置')
          .fontSize(15)
          .fontColor('#1677FF')
          .onClick(this.onOpenSettings)

        Text('关闭')
          .fontSize(15)
          .fontColor('#6B778C')
          .margin({ left: 18 })
          .onClick(this.onClose)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .padding({ left: 20, right: 20, top: 44, bottom: 12 })

      if (this.uiState.isLoading && this.uiState.sections.length === 0) {
        Column() {
          Text('加载中')
            .fontSize(AppTypography.body)
            .fontColor(AppColors.textSecondary)
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List() {
          ListItem() {
            if (this.uiState.sections.length === 0) {
              Text('暂无历史记录')
                .fontSize(AppTypography.body)
                .fontColor(AppColors.textSecondary)
                .width('100%')
                .textAlign(TextAlign.Center)
                .padding({ top: 16, bottom: 42 })
            }
          }

          ForEach(this.uiState.sections, (section: HistorySectionUiModel) => {
            ListItem() {
              this.historySection(section)
            }
          })

          ListItem() {
            if (this.uiState.isRefreshing) {
              Text('正在刷新')
                .fontSize(12)
                .fontColor(AppColors.textSecondary)
                .width('100%')
                .textAlign(TextAlign.Center)
                .padding({ top: 12, bottom: 12 })
            }
          }
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 20, right: 20, bottom: 24 })
        .edgeEffect(EdgeEffect.None)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F6FAFF')
  }

  @Builder
  private historySection(section: HistorySectionUiModel) {
    Column() {
      Text(section.title)
        .fontSize(13)
        .fontColor(AppColors.textSecondary)
        .margin({ top: 14, bottom: 8 })

      ForEach(section.items, (item: HistoryItemUiModel) => {
        this.historyRow(item)
      })
    }
    .width('100%')
  }

  @Builder
  private historyRow(item: HistoryItemUiModel) {
    Row() {
      Text(item.title)
        .fontSize(14)
        .fontColor(AppColors.textSecondary)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      if (item.displayTime.length > 0) {
        Text(` ${item.displayTime}`)
          .fontSize(12)
          .fontColor('#9AA5B5')
          .maxLines(1)
      }
    }
    .padding({ left: 16, right: 16, top: 9, bottom: 9 })
    .backgroundColor(AppColors.surface)
    .borderRadius(AppRadius.panel)
    .margin({ bottom: 8 })
    .onClick(() => {
      let historyId = Number(item.id)
      if (historyId > 0) {
        this.onSelectHistory(historyId)
      }
    })
  }

  private async refresh(): Promise<void> {
    if (!historyRuntimeStore.hasLoadedRecords()) {
      this.uiState = {
        title: '历史会话',
        sections: new Array<HistorySectionUiModel>(),
        isLoading: true,
        isRefreshing: false,
        isDeleting: false,
        hasMore: false,
        errorMessage: null
      }
    }
    this.uiState = await historyRuntimeStore.refresh()
  }
}
