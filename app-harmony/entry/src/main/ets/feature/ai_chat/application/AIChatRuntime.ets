import {
  AIChatIntentType,
  ChartPayload,
  ConversationRole,
  FeedbackState,
  FunctionName
} from '../../../core/model/ContractModelExports'
import {
  AIChatRepository,
  LoadChartDataUseCase,
  LoadChartResultKind,
  LoadHistoryDetailUseCase,
  LoadTemplateUseCase,
  MockAIChatRepository,
  SendFunctionMessageUseCase,
  SendFunctionResultKind,
  SendLikeFeedbackUseCase,
  StreamAIResponseUseCase
} from './AIChatRepository'
import {
  AIChatMessageContentKind,
  AIChatMessageUiModel,
  AIChatUiState,
  aiChatChartFallbackText,
  aiChatChartTitle,
  aiChatGenericErrorText,
  buildAIChatUiState,
  initialAIChatUiState,
  makeLoadingMessage,
  makeUserMessage,
  mapConversationMessages,
  replaceLastMessage,
  updateMessageFeedback
} from './AIChatState'

export class AIChatRuntimeStore {
  private loadTemplateUseCase: LoadTemplateUseCase
  private loadHistoryDetailUseCase: LoadHistoryDetailUseCase
  private sendFunctionMessageUseCase: SendFunctionMessageUseCase
  private loadChartDataUseCase: LoadChartDataUseCase
  private sendLikeFeedbackUseCase: SendLikeFeedbackUseCase
  private streamAIResponseUseCase: StreamAIResponseUseCase
  private state: AIChatUiState = initialAIChatUiState()
  private messageCounter: number = 0

  constructor(repository: AIChatRepository = new MockAIChatRepository()) {
    this.loadTemplateUseCase = new LoadTemplateUseCase(repository)
    this.loadHistoryDetailUseCase = new LoadHistoryDetailUseCase(repository)
    this.sendFunctionMessageUseCase = new SendFunctionMessageUseCase(repository)
    this.loadChartDataUseCase = new LoadChartDataUseCase(repository)
    this.sendLikeFeedbackUseCase = new SendLikeFeedbackUseCase(repository)
    this.streamAIResponseUseCase = new StreamAIResponseUseCase(repository)
  }

  snapshot(): AIChatUiState {
    return this.state
  }

  updateInput(text: string): AIChatUiState {
    this.state = buildAIChatUiState(
      this.state.historyId ?? null,
      this.state.messages,
      this.state.templateQuestions,
      text,
      this.state.isLoadingTemplate,
      this.state.isSending,
      this.state.isStreaming,
      null,
      false
    )
    return this.state
  }

  async loadTemplate(): Promise<AIChatUiState> {
    this.state = buildAIChatUiState(null, new Array<AIChatMessageUiModel>(), new Array<string>(), '', true, false, false, null, false)
    try {
      let questions = await this.loadTemplateUseCase.execute()
      this.state = buildAIChatUiState(null, new Array<AIChatMessageUiModel>(), questions, '', false, false, false, null, false)
    } catch (error) {
      this.state = buildAIChatUiState(null, new Array<AIChatMessageUiModel>(), new Array<string>(), '', false, false, false, aiChatGenericErrorText, false)
    }
    return this.state
  }

  async resetConversation(): Promise<AIChatUiState> {
    this.state = initialAIChatUiState()
    return this.loadTemplate()
  }

  async loadHistoryDetail(historyId: number): Promise<AIChatUiState> {
    this.state = buildAIChatUiState(historyId, new Array<AIChatMessageUiModel>(), new Array<string>(), '', false, true, false, null, false)
    try {
      let messages = mapConversationMessages(await this.loadHistoryDetailUseCase.execute(historyId))
      this.state = buildAIChatUiState(historyId, messages, new Array<string>(), '', false, false, false, null, true)
    } catch (error) {
      this.state = buildAIChatUiState(historyId, new Array<AIChatMessageUiModel>(), new Array<string>(), '', false, false, false, aiChatGenericErrorText, false)
    }
    return this.state
  }

  async sendMessage(text: string): Promise<AIChatUiState> {
    let trimmed = text.trim()
    if (trimmed.length === 0 || this.state.isSending || this.state.isStreaming) {
      return this.state
    }

    let userMessage = makeUserMessage(this.nextId('local-user'), trimmed)
    let loadingMessage = makeLoadingMessage(this.nextId('local-assistant-loading'))
    let messages = this.state.messages.concat([userMessage, loadingMessage])
    let activeHistoryId = this.state.historyId ?? null
    this.state = buildAIChatUiState(activeHistoryId, messages, this.state.templateQuestions, '', false, true, false, null, true)

    let result = await this.sendFunctionMessageUseCase.execute(trimmed, activeHistoryId)
    if (result.kind === SendFunctionResultKind.Intent) {
      this.state = buildAIChatUiState(
        activeHistoryId,
        replaceLastMessage(this.state.messages, this.makeIntentMessage(result.text ?? '需要补充查询条件', result.intentType ?? AIChatIntentType.Time)),
        new Array<string>(),
        '',
        false,
        false,
        false,
        null,
        true
      )
      return this.state
    }

    if (result.kind === SendFunctionResultKind.ChartRequest && result.name !== null && result.name !== undefined && result.historyId !== null && result.historyId !== undefined && result.argumentsValue !== null && result.argumentsValue !== undefined) {
      let chartResult = await this.loadChartDataUseCase.execute(result.name, result.historyId, result.argumentsValue)
      if (chartResult.kind === LoadChartResultKind.Chart && chartResult.payload !== null && chartResult.payload !== undefined) {
        this.state = buildAIChatUiState(
          result.historyId,
          replaceLastMessage(this.state.messages, this.makeChartMessage(chartResult.payload, result.name)),
          new Array<string>(),
          '',
          false,
          false,
          false,
          null,
          true
        )
        return this.state
      }
      this.state = buildAIChatUiState(
        result.historyId,
        replaceLastMessage(this.state.messages, this.makeErrorMessage(chartResult.message ?? aiChatChartFallbackText, result.name)),
        new Array<string>(),
        '',
        false,
        false,
        false,
        null,
        true
      )
      return this.state
    }

    await this.streamAnswer(trimmed)
    return this.state
  }

  async sendFeedback(historyDetailId: number, like: string): Promise<AIChatUiState> {
    let target = like === '1' ? FeedbackState.Liked : FeedbackState.Disliked
    let previous = this.state.messages
    this.state = buildAIChatUiState(
      this.state.historyId ?? null,
      updateMessageFeedback(this.state.messages, historyDetailId, target),
      this.state.templateQuestions,
      this.state.inputText,
      this.state.isLoadingTemplate,
      this.state.isSending,
      this.state.isStreaming,
      null,
      false
    )
    try {
      await this.sendLikeFeedbackUseCase.execute(historyDetailId, like)
    } catch (error) {
      this.state = buildAIChatUiState(
        this.state.historyId ?? null,
        previous,
        this.state.templateQuestions,
        this.state.inputText,
        this.state.isLoadingTemplate,
        this.state.isSending,
        this.state.isStreaming,
        '反馈发送失败',
        false
      )
    }
    return this.state
  }

  private async streamAnswer(text: string): Promise<void> {
    let streamMessage = this.makeStreamingMessage('')
    this.state = buildAIChatUiState(
      this.state.historyId ?? null,
      replaceLastMessage(this.state.messages, streamMessage),
      new Array<string>(),
      '',
      false,
      false,
      true,
      null,
      true
    )
    try {
      let chunks = await this.streamAIResponseUseCase.execute(text)
      let currentText = ''
      for (let index = 0; index < chunks.length; index++) {
        currentText += chunks[index]
        this.state = buildAIChatUiState(
          this.state.historyId ?? null,
          replaceLastMessage(this.state.messages, this.makeStreamingMessage(currentText)),
          new Array<string>(),
          '',
          false,
          false,
          true,
          null,
          true
        )
      }
      this.state = buildAIChatUiState(
        this.state.historyId ?? null,
        replaceLastMessage(this.state.messages, this.makeTextMessage(currentText)),
        new Array<string>(),
        '',
        false,
        false,
        false,
        null,
        true
      )
    } catch (error) {
      this.state = buildAIChatUiState(
        this.state.historyId ?? null,
        replaceLastMessage(this.state.messages, this.makeErrorMessage(aiChatGenericErrorText, null)),
        new Array<string>(),
        '',
        false,
        false,
        false,
        null,
        true
      )
    }
  }

  private makeIntentMessage(text: string, intentType: AIChatIntentType): AIChatMessageUiModel {
    return {
      id: this.nextId('local-assistant-intent'),
      role: ConversationRole.Assistant,
      contentKind: AIChatMessageContentKind.Intent,
      text: text,
      intentType: intentType,
      feedback: FeedbackState.None,
      templateQuestions: new Array<string>(),
      isStreaming: false
    }
  }

  private makeChartMessage(payload: ChartPayload, functionName: FunctionName): AIChatMessageUiModel {
    return {
      id: this.nextId('local-assistant-chart'),
      role: ConversationRole.Assistant,
      contentKind: AIChatMessageContentKind.Chart,
      text: aiChatChartTitle,
      chartPayload: payload,
      feedback: FeedbackState.None,
      historyDetailId: 2002,
      functionName: functionName,
      templateQuestions: new Array<string>(),
      isStreaming: false
    }
  }

  private makeTextMessage(text: string): AIChatMessageUiModel {
    return {
      id: this.nextId('local-assistant-text'),
      role: ConversationRole.Assistant,
      contentKind: AIChatMessageContentKind.Text,
      text: text,
      feedback: FeedbackState.None,
      templateQuestions: new Array<string>(),
      isStreaming: false
    }
  }

  private makeStreamingMessage(text: string): AIChatMessageUiModel {
    return {
      id: 'local-assistant-stream-1',
      role: ConversationRole.Assistant,
      contentKind: AIChatMessageContentKind.Text,
      text: text,
      feedback: FeedbackState.None,
      templateQuestions: new Array<string>(),
      isStreaming: true
    }
  }

  private makeErrorMessage(text: string, functionName?: FunctionName | null): AIChatMessageUiModel {
    return {
      id: this.nextId('local-assistant-fallback'),
      role: ConversationRole.Assistant,
      contentKind: AIChatMessageContentKind.Error,
      text: text,
      feedback: FeedbackState.None,
      functionName: functionName ?? null,
      templateQuestions: new Array<string>(),
      isStreaming: false
    }
  }

  private nextId(prefix: string): string {
    this.messageCounter += 1
    return `${prefix}-${this.messageCounter}`
  }
}

export const aiChatRuntimeStore = new AIChatRuntimeStore()
