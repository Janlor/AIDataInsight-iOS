@Component
export struct PrivacyPage {
  build() {
    Column() {
      Text('Privacy')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
      Text('待接入本地隐私政策页面')
        .fontSize(14)
        .opacity(0.7)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
