import { ChartPayload, ChartSeries, ChartUnit, ConversationRole, FeedbackState } from '../../../core/model/ContractModelExports'
import { AppColors, AppSpacing, AppTypography } from '../../../core/ui/theme/AppTheme'
import { aiChatRuntimeStore } from '../application/AIChatRuntime'
import {
  AIChatMessageContentKind,
  AIChatMessageUiModel,
  AIChatUiState,
  aiChatInputPlaceholder,
  aiChatWelcomePrompt,
  initialAIChatUiState,
  makeWelcomeMessage
} from '../application/AIChatState'

interface QueryExampleSegment {
  top: string
  bottom: string
  isRegular?: boolean
}

@Component
export struct AIChatPage {
  @Prop @Watch('onConversationInputChanged') selectedHistoryId: number | null = null
  @Prop @Watch('onConversationInputChanged') conversationVersion: number = 0
  @Prop drawBackground: boolean = true

  @State uiState: AIChatUiState = initialAIChatUiState()

  private readonly exampleSegments: Array<QueryExampleSegment> = [
    { top: '今年第一季度', bottom: '时间范围' },
    { top: '销售额', bottom: '指标名称' },
    { top: '大于5000万', bottom: '过滤条件' },
    { top: '的', bottom: '', isRegular: true },
    { top: '公司。', bottom: '分组维度' }
  ]

  aboutToAppear() {
    this.uiState = aiChatRuntimeStore.snapshot()
    this.syncConversation()
  }

  build() {
    Stack() {
      if (this.drawBackground) {
        Image($r('app.media.background_vc'))
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
      }

      Column() {
        Scroll() {
          Column() {
            if (this.uiState.isLoadingTemplate) {
              this.loadingBubble('正在加载推荐问题')
            } else if (this.uiState.messages.length === 0 && this.uiState.templateQuestions.length > 0) {
              this.messageBubble(makeWelcomeMessage(this.uiState.templateQuestions))
            }

            ForEach(this.uiState.messages, (message: AIChatMessageUiModel) => {
              this.messageBubble(message)
            })
          }
          .width('100%')
          .padding({ top: 8, bottom: 12 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)

        if (this.uiState.errorMessage !== null && this.uiState.errorMessage !== undefined) {
          this.errorToast(this.uiState.errorMessage ?? '')
        }

        this.composer()
      }
      .width('100%')
      .height('100%')
      .padding({ left: 0, right: 0, bottom: 0 })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private errorToast(message: string) {
    Row() {
      Text(message)
        .fontSize(AppTypography.footnote)
        .fontColor(AppColors.danger)
        .layoutWeight(1)
      Text('关闭')
        .fontSize(AppTypography.footnote)
        .fontColor(AppColors.accent)
        .padding({ left: 12, right: 2, top: 4, bottom: 4 })
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .padding({ left: 14, right: 12, top: 10, bottom: 10 })
    .backgroundColor('#FFFFF6F5')
    .border({ width: 1, color: '#FFFFD7D2' })
    .borderRadius(14)
    .margin({ bottom: 8 })
  }

  @Builder
  private messageBubble(message: AIChatMessageUiModel) {
    if (message.role === ConversationRole.User) {
      Row() {
        Blank()
        Column() {
          Text(message.text ?? '')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor(AppColors.textPrimary)
            .lineHeight(22)
            .maxLines(12)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .constraintSize({ maxWidth: '82%' })
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
        .linearGradient({
          angle: 135,
          colors: [
            ['#FFF5FAFF', 0],
            ['#FFEAF5FF', 0.48],
            ['#FFD1E8FF', 1]
          ]
        })
        .borderRadius({ topLeft: 21, topRight: 21, bottomLeft: 21, bottomRight: 4 })
      }
      .width('100%')
      .margin({ bottom: 10 })
    } else {
      Column() {
        Column() {
          if (message.contentKind === AIChatMessageContentKind.Welcome) {
            this.welcomeContent(message)
          } else if (message.contentKind === AIChatMessageContentKind.Chart && message.chartPayload !== null && message.chartPayload !== undefined) {
            this.chartContent(message)
          } else {
            this.textContent(message)
          }
        }
        .constraintSize({ maxWidth: '88%' })
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
        .backgroundColor('#F8FFFFFF')
        .border({ width: 1, color: '#DDE6F0' })
        .borderRadius({ topLeft: 21, topRight: 21, bottomLeft: 4, bottomRight: 21 })

        if (message.contentKind === AIChatMessageContentKind.Chart) {
          this.feedbackBar(message)
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: 10 })
    }
  }

  @Builder
  private welcomeContent(message: AIChatMessageUiModel) {
    Text(message.text ?? '')
      .fontSize(15)
      .fontColor(AppColors.textPrimary)
      .lineHeight(23)

    Text(aiChatWelcomePrompt)
      .fontSize(15)
      .fontColor(AppColors.textPrimary)
      .lineHeight(23)
      .margin({ top: 4, bottom: 2 })

    ForEach(message.templateQuestions, (question: string, index: number) => {
      Text(question)
        .fontSize(15)
        .fontColor(AppColors.accent)
        .lineHeight(22)
        .width('100%')
        .padding({ top: 10, bottom: 10 })
        .border({ width: { top: index === 0 ? 0 : 1 }, color: '#E1E7EF' })
        .onClick(() => {
          this.sendText(question)
        })
    })

    Text('我能精准识别问题中的指标名称、时间范围、分组维度和过滤条件，例如：')
      .fontSize(15)
      .fontColor(AppColors.textPrimary)
      .lineHeight(22)
      .margin({ top: 10 })

    Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
      ForEach(this.exampleSegments, (segment: QueryExampleSegment) => {
        this.exampleSegment(segment)
      })
    }
    .width('100%')
    .margin({ top: 10 })
  }

  @Builder
  private exampleSegment(segment: QueryExampleSegment) {
    Column() {
      Text(segment.top)
        .fontSize(12)
        .fontWeight(segment.isRegular === true ? FontWeight.Regular : FontWeight.Medium)
        .fontColor(AppColors.textPrimary)
        .maxLines(1)
      Text(segment.bottom)
        .fontSize(10)
        .fontColor('#8B95A5')
        .height(14)
        .maxLines(1)
    }
    .alignItems(HorizontalAlign.Center)
    .margin({ right: 8, bottom: 8 })
  }

  @Builder
  private textContent(message: AIChatMessageUiModel) {
    Text(message.text ?? '')
      .fontSize(15)
      .fontColor(message.contentKind === AIChatMessageContentKind.Error ? AppColors.danger : AppColors.textPrimary)
      .lineHeight(23)
    if (message.isStreaming) {
      Row() {
        LoadingProgress()
          .width(14)
          .height(14)
          .color(AppColors.accent)
        Text('生成中')
          .fontSize(12)
          .fontColor(AppColors.textSecondary)
          .margin({ left: 6 })
      }
      .alignItems(VerticalAlign.Center)
      .margin({ top: 8 })
    }
  }

  @Builder
  private chartContent(message: AIChatMessageUiModel) {
    Text(message.text ?? '根据您的查询，以下是分析结果:')
      .fontSize(13)
      .fontColor(AppColors.textSecondary)
      .lineHeight(20)
      .fontWeight(FontWeight.Medium)
    this.chartPayloadView(message.chartPayload as ChartPayload)
  }

  @Builder
  private loadingBubble(text: string) {
    Row() {
      Column() {
        Row() {
          LoadingProgress()
            .width(16)
            .height(16)
            .color(AppColors.accent)
          Text(text)
            .fontSize(15)
            .fontColor(AppColors.textSecondary)
            .margin({ left: 8 })
        }
        .alignItems(VerticalAlign.Center)
      }
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor('#F8FFFFFF')
      .border({ width: 1, color: '#DDE6F0' })
      .borderRadius({ topLeft: 21, topRight: 21, bottomLeft: 4, bottomRight: 21 })
      Blank()
    }
    .width('100%')
  }

  @Builder
  private chartPayloadView(payload: ChartPayload) {
    if (payload.series.length === 0) {
      Text(payload.emptyMessage ?? '数据分析还在测试阶段，很快就能上线，敬请期待！')
        .fontSize(15)
        .fontColor(AppColors.textPrimary)
        .lineHeight(22)
        .margin({ top: 8 })
    } else {
      Column() {
        Text(payload.unit === ChartUnit.Ton ? '单位：万吨' : '单位：万元')
          .fontSize(11)
          .fontColor('#8B95A5')
          .width('100%')
          .margin({ bottom: 8 })

        ForEach(payload.series.slice(0, 7), (series: ChartSeries) => {
          this.chartRow(series, this.maxChartValue(payload.series))
        })

        this.chartLegend(payload)
      }
      .width('100%')
      .margin({ top: 10 })
    }
  }

  @Builder
  private chartRow(series: ChartSeries, maxValue: number) {
    Column() {
      Row() {
        Text(series.xAxis)
          .fontSize(11)
          .fontColor('#6B778C')
          .width(72)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Stack({ alignContent: Alignment.Start }) {
          Row()
            .height(12)
            .width('100%')
            .backgroundColor('#EEF3F8')
            .borderRadius(6)
          Row()
            .height(12)
            .width(`${this.chartWidthPercent(series, maxValue)}%`)
            .linearGradient({
              angle: 90,
              colors: [
                ['#FF5CA4FF', 0],
                ['#FF1677FF', 1]
              ]
            })
            .borderRadius(6)
        }
        .height(12)
        .layoutWeight(1)
        Text(this.displayChartValue(series))
          .fontSize(11)
          .fontColor('#6B778C')
          .width(42)
          .textAlign(TextAlign.End)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .margin({ bottom: 9 })
  }

  @Builder
  private chartLegend(payload: ChartPayload) {
    Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
      ForEach(this.legendLabels(payload), (label: string, index: number) => {
        Row() {
          Row()
            .width(8)
            .height(8)
            .borderRadius(4)
            .backgroundColor(this.legendColor(index))
          Text(label)
            .fontSize(11)
            .fontColor(AppColors.textSecondary)
            .margin({ left: 4 })
        }
        .alignItems(VerticalAlign.Center)
        .margin({ right: 10, bottom: 6 })
      })
    }
    .width('100%')
    .margin({ top: 2 })
  }

  @Builder
  private feedbackBar(message: AIChatMessageUiModel) {
    if (message.historyDetailId !== null && message.historyDetailId !== undefined) {
      Row() {
        this.feedbackButton(
          message.feedback === FeedbackState.Liked,
          $r(message.feedback === FeedbackState.Liked ? 'app.media.like_selected' : 'app.media.like_normal'),
          () => {
            if (message.feedback !== FeedbackState.Liked && message.historyDetailId !== null && message.historyDetailId !== undefined) {
              this.sendFeedback(message.historyDetailId ?? 0, '1')
            }
          }
        )
        Row()
          .width(1)
          .height(20)
          .backgroundColor('#E1E7EF')
        this.feedbackButton(
          message.feedback === FeedbackState.Disliked,
          $r(message.feedback === FeedbackState.Disliked ? 'app.media.unlike_selected' : 'app.media.unlike_normal'),
          () => {
            if (message.feedback !== FeedbackState.Disliked && message.historyDetailId !== null && message.historyDetailId !== undefined) {
              this.sendFeedback(message.historyDetailId ?? 0, '0')
            }
          }
        )
      }
      .height(32)
      .backgroundColor('#F8FFFFFF')
      .border({ width: 1, color: '#DDE6F0' })
      .borderRadius(16)
      .alignItems(VerticalAlign.Center)
      .margin({ top: 8, left: 2 })
    }
  }

  @Builder
  private feedbackButton(selected: boolean, icon: Resource, action: () => void) {
    Row() {
      Image(icon)
        .width(18)
        .height(18)
        .objectFit(ImageFit.Contain)
        .opacity(selected ? 1 : 0.86)
    }
    .width(58)
    .height(30)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .enabled(!selected)
    .onClick(action)
  }

  @Builder
  private composer() {
    Row() {
      TextInput({ placeholder: aiChatInputPlaceholder, text: this.uiState.inputText })
        .layoutWeight(1)
        .height(34)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppColors.textPrimary)
        .placeholderColor('#9AA4B2')
        .backgroundColor(Color.Transparent)
        .padding({ left: 0, right: 0 })
        .enabled(!this.uiState.isSending && !this.uiState.isStreaming)
        .onChange((value: string) => {
          this.uiState = aiChatRuntimeStore.updateInput(value)
        })

      Button() {
        Image($r('app.media.send'))
          .width(22)
          .height(22)
          .objectFit(ImageFit.Contain)
          .opacity(this.uiState.canSend ? 1 : 0.2)
      }
      .width(54)
      .height(34)
      .backgroundColor(Color.Transparent)
      .enabled(this.uiState.canSend)
      .onClick(() => {
        if (this.uiState.canSend) {
          this.sendText(this.uiState.inputText)
        }
      })
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .padding({ left: 16, right: 4, top: 4, bottom: 4 })
    .backgroundColor('#F8FFFFFF')
    .border({ width: 1, color: '#DDE6F0' })
    .borderRadius(21)
    .margin({ top: AppSpacing.itemGap, bottom: 2 })
  }

  private onConversationInputChanged(): void {
    this.syncConversation()
  }

  private async syncConversation(): Promise<void> {
    if (this.selectedHistoryId !== null) {
      this.uiState = await aiChatRuntimeStore.loadHistoryDetail(this.selectedHistoryId)
      return
    }
    this.uiState = await aiChatRuntimeStore.resetConversation()
  }

  private async sendText(text: string): Promise<void> {
    this.uiState = aiChatRuntimeStore.updateInput(text)
    this.uiState = await aiChatRuntimeStore.sendMessage(text)
  }

  private async sendFeedback(historyDetailId: number, like: string): Promise<void> {
    this.uiState = await aiChatRuntimeStore.sendFeedback(historyDetailId, like)
  }

  private maxChartValue(series: Array<ChartSeries>): number {
    let maxValue = 0
    for (let index = 0; index < series.length; index++) {
      let total = this.seriesTotal(series[index])
      if (total > maxValue) {
        maxValue = total
      }
    }
    return maxValue
  }

  private seriesTotal(series: ChartSeries): number {
    let total = 0
    for (let index = 0; index < series.values.length; index++) {
      total += series.values[index]
    }
    return total
  }

  private chartWidthPercent(series: ChartSeries, maxValue: number): number {
    if (maxValue <= 0) {
      return 8
    }
    return Math.max(8, Math.round(this.seriesTotal(series) / maxValue * 100))
  }

  private displayChartValue(series: ChartSeries): string {
    return `${Math.round(this.seriesTotal(series) / 10000)}`
  }

  private legendLabels(payload: ChartPayload): Array<string> {
    if (payload.series.length === 0) {
      return new Array<string>()
    }
    if (payload.series[0].labels.length > 0) {
      return payload.series[0].labels
    }
    let labels = new Array<string>()
    for (let index = 0; index < Math.min(payload.series.length, 7); index++) {
      labels.push(payload.series[index].xAxis)
    }
    return labels
  }

  private legendColor(index: number): string {
    const colors = ['#1677FF', '#5CA4FF', '#52C41A', '#FAAD14', '#F759AB', '#722ED1', '#13C2C2']
    return colors[index % colors.length]
  }
}
