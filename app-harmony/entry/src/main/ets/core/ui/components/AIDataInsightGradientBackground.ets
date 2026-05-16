@Component
export struct AIDataInsightGradientBackground {
  build() {
    Column()
      .width('100%')
      .height('100%')
      .backgroundColor('#F7FAFE')
      .linearGradient({
        angle: 135,
        colors: [
          ['#142F7BFF', 0.0],
          ['#0518B8FF', 0.3],
          ['#0518B8FF', 0.7],
          ['#0F2F7BFF', 1.0]
        ]
      })
  }
}
