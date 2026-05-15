@Component
export struct AIHomePage {
  build() {
    Column() {
      Text('AI Home')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
      Text('HarmonyOS NEXT placeholder')
        .fontSize(14)
        .opacity(0.7)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
