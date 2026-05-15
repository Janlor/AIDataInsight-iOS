@Component
export struct AIChatPage {
  selectedHistoryId: number | null = null
  conversationVersion: number = 0

  build() {
    Column() {
      Text('AI Chat')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)

      if (this.selectedHistoryId !== null) {
        Text(`正在查看历史会话 #${this.selectedHistoryId}`)
          .fontSize(14)
          .opacity(0.7)
          .margin({ top: 8 })
      } else {
        Text('新会话')
          .fontSize(14)
          .opacity(0.7)
          .margin({ top: 8 })
      }

      Text(`conversationVersion: ${this.conversationVersion}`)
        .fontSize(14)
        .opacity(0.7)
        .margin({ top: 6 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
