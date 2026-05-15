@Component
export struct SettingPage {
  onBack: () => void = () => {}

  build() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(15)
          .fontColor('#1677FF')
          .onClick(this.onBack)

        Text('设置')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Text(' ')
          .fontSize(15)
          .width(32)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Text('账户信息')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .margin({ top: 32 })

      Text('待接入账户信息、隐私政策、版本号和退出登录')
        .fontSize(14)
        .opacity(0.7)
        .width('100%')
        .margin({ top: 10 })
    }
    .width('100%')
    .height('100%')
    .padding({ left: 24, right: 24, top: 44, bottom: 34 })
  }
}
