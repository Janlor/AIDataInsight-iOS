@Component
export struct AIChatPage {
  build() {
    Column() {
      Text('AI Chat')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
      Text('待接入模板问题、流式回复、图表和反馈')
        .fontSize(14)
        .opacity(0.7)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
