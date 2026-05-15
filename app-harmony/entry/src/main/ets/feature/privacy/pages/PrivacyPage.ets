@Component
export struct PrivacyPage {
  onBack: () => void = () => {}

  build() {
    Column() {
      Text('返回')
        .fontSize(15)
        .fontColor('#1677FF')
        .width('100%')
        .textAlign(TextAlign.Start)
        .onClick(this.onBack)

      Text('Privacy')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 36 })

      Text('待接入本地隐私政策页面')
        .fontSize(14)
        .opacity(0.7)
    }
    .width('100%')
    .height('100%')
    .padding({ left: 24, right: 24, top: 20, bottom: 20 })
  }
}
