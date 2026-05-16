import { ChartPayload, ChartSeries, ChartUnit, ConversationRole, FeedbackState } from '../../../core/model/ContractModelExports'
import { AppColors, AppRadius, AppSpacing, AppTypography } from '../../../core/ui/theme/AppTheme'
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

@Component
export struct AIChatPage {
  @Prop @Watch('onConversationInputChanged') selectedHistoryId: number | null = null
  @Prop @Watch('onConversationInputChanged') conversationVersion: number = 0

  @State uiState: AIChatUiState = initialAIChatUiState()

  aboutToAppear() {
    this.uiState = aiChatRuntimeStore.snapshot()
    this.syncConversation()
  }

  build() {
    Column() {
      if (this.uiState.errorMessage !== null && this.uiState.errorMessage !== undefined) {
        Text(this.uiState.errorMessage ?? '')
          .fontSize(AppTypography.footnote)
          .fontColor(AppColors.danger)
          .width('100%')
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .backgroundColor('#FFF1F0')
          .borderRadius(AppRadius.panel)
          .margin({ bottom: 8 })
      }

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
        .padding({ bottom: 12 })
      }
      .layoutWeight(1)

      this.composer()
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private messageBubble(message: AIChatMessageUiModel) {
    Row() {
      if (message.role === ConversationRole.User) {
        Blank()
      }

      Column() {
        if (message.contentKind === AIChatMessageContentKind.Welcome) {
          Text(message.text ?? '')
            .fontSize(AppTypography.body)
            .fontColor(AppColors.textPrimary)
            .lineHeight(22)
          Text(aiChatWelcomePrompt)
            .fontSize(AppTypography.footnote)
            .fontColor(AppColors.textSecondary)
            .margin({ top: 10, bottom: 4 })
          ForEach(message.templateQuestions, (question: string) => {
            Text(question)
              .fontSize(AppTypography.body)
              .fontColor(AppColors.accent)
              .width('100%')
              .padding({ top: 8, bottom: 8 })
              .border({ width: { top: 1 }, color: AppColors.divider })
              .onClick(() => {
                this.sendText(question)
              })
          })
        } else if (message.contentKind === AIChatMessageContentKind.Chart && message.chartPayload !== null && message.chartPayload !== undefined) {
          Text(message.text ?? '')
            .fontSize(AppTypography.body)
            .fontColor(AppColors.textPrimary)
            .fontWeight(FontWeight.Medium)
          this.chartFallback(message.chartPayload)
          this.feedbackBar(message)
        } else {
          Text(message.text ?? '')
            .fontSize(AppTypography.body)
            .fontColor(message.contentKind === AIChatMessageContentKind.Error ? AppColors.danger : AppColors.textPrimary)
            .lineHeight(22)
          if (message.isStreaming) {
            Text('生成中')
              .fontSize(12)
              .fontColor(AppColors.textSecondary)
              .margin({ top: 4 })
          }
        }
      }
      .constraintSize({ maxWidth: '82%' })
      .padding({ left: 14, right: 14, top: 12, bottom: 12 })
      .backgroundColor(message.role === ConversationRole.User ? '#DDEEFF' : AppColors.surface)
      .borderRadius(AppRadius.panel)
      .border({ width: message.role === ConversationRole.User ? 0 : 1, color: AppColors.divider })

      if (message.role !== ConversationRole.User) {
        Blank()
      }
    }
    .width('100%')
    .margin({ bottom: 10 })
  }

  @Builder
  private loadingBubble(text: string) {
    Row() {
      Column() {
        Text(text)
          .fontSize(AppTypography.body)
          .fontColor(AppColors.textSecondary)
      }
      .padding({ left: 14, right: 14, top: 12, bottom: 12 })
      .backgroundColor(AppColors.surface)
      .borderRadius(AppRadius.panel)
      Blank()
    }
    .width('100%')
  }

  @Builder
  private chartFallback(payload: ChartPayload) {
    if (payload.series.length === 0) {
      Text(payload.emptyMessage ?? '数据分析还在测试阶段，很快就能上线，敬请期待！')
        .fontSize(AppTypography.body)
        .fontColor(AppColors.textSecondary)
        .margin({ top: 8 })
    } else {
      Column() {
        Text(payload.unit === ChartUnit.Ton ? '单位：万吨' : '单位：万元')
          .fontSize(12)
          .fontColor(AppColors.textSecondary)
          .width('100%')
          .margin({ bottom: 8 })
        ForEach(payload.series, (series: ChartSeries) => {
          this.chartRow(series, this.maxChartValue(payload.series))
        })
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
          .fontSize(12)
          .fontColor(AppColors.textSecondary)
          .width(76)
        Row()
          .height(12)
          .width(`${this.chartWidthPercent(series, maxValue)}%`)
          .backgroundColor(AppColors.accent)
          .borderRadius(6)
        Text(`${Math.round(this.firstSeriesValue(series) / 10000)}`)
          .fontSize(12)
          .fontColor(AppColors.textSecondary)
          .margin({ left: 8 })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .margin({ top: 6 })
  }

  @Builder
  private feedbackBar(message: AIChatMessageUiModel) {
    if (message.historyDetailId !== null && message.historyDetailId !== undefined) {
      Row() {
        Text(message.feedback === FeedbackState.Liked ? '已赞' : '赞')
          .fontSize(12)
          .fontColor(message.feedback === FeedbackState.Liked ? AppColors.accent : AppColors.textSecondary)
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .onClick(() => {
            if (message.feedback !== FeedbackState.Liked && message.historyDetailId !== null && message.historyDetailId !== undefined) {
              this.sendFeedback(message.historyDetailId ?? 0, '1')
            }
          })
        Text(message.feedback === FeedbackState.Disliked ? '已踩' : '踩')
          .fontSize(12)
          .fontColor(message.feedback === FeedbackState.Disliked ? AppColors.danger : AppColors.textSecondary)
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .onClick(() => {
            if (message.feedback !== FeedbackState.Disliked && message.historyDetailId !== null && message.historyDetailId !== undefined) {
              this.sendFeedback(message.historyDetailId ?? 0, '0')
            }
          })
      }
      .justifyContent(FlexAlign.End)
      .width('100%')
      .margin({ top: 8 })
    }
  }

  @Builder
  private composer() {
    Row() {
      TextInput({ placeholder: aiChatInputPlaceholder, text: this.uiState.inputText })
        .layoutWeight(1)
        .height(42)
        .backgroundColor(AppColors.surface)
        .borderRadius(21)
        .enabled(!this.uiState.isSending && !this.uiState.isStreaming)
        .onChange((value: string) => {
          this.uiState = aiChatRuntimeStore.updateInput(value)
        })

      Text(this.uiState.isSending || this.uiState.isStreaming ? '发送中' : '发送')
        .fontSize(AppTypography.body)
        .fontColor(this.uiState.canSend ? AppColors.accent : AppColors.textSecondary)
        .padding({ left: 12, right: 4, top: 10, bottom: 10 })
        .onClick(() => {
          if (this.uiState.canSend) {
            this.sendText(this.uiState.inputText)
          }
        })
    }
    .width('100%')
    .padding({ left: 10, right: 10, top: 8, bottom: 8 })
    .backgroundColor('#EEF5FC')
    .borderRadius(26)
    .margin({ top: AppSpacing.itemGap })
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
      let value = series[index].values.length > 0 ? series[index].values[0] : 0
      if (value > maxValue) {
        maxValue = value
      }
    }
    return maxValue
  }

  private firstSeriesValue(series: ChartSeries): number {
    return series.values.length > 0 ? series.values[0] : 0
  }

  private chartWidthPercent(series: ChartSeries, maxValue: number): number {
    if (maxValue <= 0) {
      return 8
    }
    return Math.max(8, Math.round(this.firstSeriesValue(series) / maxValue * 100))
  }
}
