@Component
export struct LoginPage {
  build() {
    Column() {
      Text('Login')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
      Text('待接入登录契约、账号服务和隐私协议')
        .fontSize(14)
        .opacity(0.7)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
