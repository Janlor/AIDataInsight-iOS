@Component
export struct HistoryPage {
  onClose: () => void = () => {}
  onOpenSettings: () => void = () => {}
  onSelectHistory: (historyId: number) => void = () => {}

  build() {
    Column() {
      Row() {
        Text('历史会话')
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

      Column() {
        this.historyRow(1001, '查看一月销售额', '今天')
        this.historyRow(1002, '仓库库存分析', '昨天')
        this.historyRow(1003, '应收账款排行', '更早')
      }
      .width('100%')
      .padding({ left: 20, right: 20 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F6FAFF')
  }

  @Builder
  private historyRow(historyId: number, title: string, subtitle: string) {
    Column() {
      Text(title)
        .fontSize(15)
        .fontColor('#17233D')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Text(subtitle)
        .fontSize(12)
        .fontColor('#6B778C')
        .margin({ top: 4 })
    }
    .width('100%')
    .padding({ top: 14, bottom: 14 })
    .border({ width: { bottom: 1 }, color: '#E6EAF0' })
    .onClick(() => {
      this.onSelectHistory(historyId)
    })
  }
}
