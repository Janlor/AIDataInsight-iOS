@Component
export struct HistoryPage {
  build() {
    Column() {
      Text('History')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
      Text('待接入历史会话列表和分组规则')
        .fontSize(14)
        .opacity(0.7)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
