@Component
export struct SettingPage {
  build() {
    Column() {
      Text('Setting')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
      Text('待接入账户信息、隐私政策、版本号和退出登录')
        .fontSize(14)
        .opacity(0.7)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
