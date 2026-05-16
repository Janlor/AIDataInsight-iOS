import {
  AIChatIntentType,
  ChartCommonItem,
  ChartPayload,
  ChartSeries,
  ChartUnit,
  ConversationContentKind,
  ConversationMessage,
  ConversationRole,
  FeedbackState,
  FunctionArgumentKind,
  FunctionArguments,
  FunctionModel,
  FunctionName,
  HistoryChartDetail,
  HistoryContentType,
  HistoryDetailType,
  HistoryRecord,
  HistoryDetail,
  TemplateQuestionSet
} from '../../../core/model/ContractModelExports'
import { mapChartPayload, mapHistoryDetailsToMessages } from '../../../contracts/mappers/ContractFixtureMappers'

export interface AIChatRepository {
  loadTemplate(): Promise<TemplateQuestionSet>
  loadHistoryDetail(historyId: number): Promise<HistoryRecord>
  sendFunctionMessage(text: string, historyId?: number | null): Promise<FunctionModel>
  loadChartData(name: FunctionName, historyId: number, argumentsValue: FunctionArguments): Promise<HistoryChartDetail>
  sendLikeFeedback(historyDetailId: number, like: string): Promise<void>
  streamMessage(text: string): Promise<Array<string>>
}

export enum SendFunctionResultKind {
  Intent = 'intent',
  ChartRequest = 'chartRequest',
  Failure = 'failure'
}

export interface SendFunctionResult {
  kind: SendFunctionResultKind
  text?: string | null
  intentType?: AIChatIntentType | null
  name?: FunctionName | null
  historyId?: number | null
  argumentsValue?: FunctionArguments | null
  message?: string | null
}

export enum LoadChartResultKind {
  Chart = 'chart',
  Failure = 'failure'
}

export interface LoadChartResult {
  kind: LoadChartResultKind
  payload?: ChartPayload | null
  message?: string | null
}

export class MockAIChatRepository implements AIChatRepository {
  private liked: Map<number, string> = new Map<number, string>()

  async loadTemplate(): Promise<TemplateQuestionSet> {
    return {
      questions: [
        '今年第三季度销售额大于2亿的公司有哪些？',
        '查看仓库中煤炭库存大于5万吨的公司。',
        '列出公司FHJK应收余额超过5000万的客户。',
        '钢材存货金额余额最多的公司？',
        '查看各公司账龄超过180天的金额。'
      ]
    }
  }

  async loadHistoryDetail(historyId: number): Promise<HistoryRecord> {
    if (historyId === 1002) {
      return {
        id: historyId,
        name: '仓库库存分析',
        createTime: '2026-05-01 14:20:00',
        updateTime: '2026-05-01 14:21:00',
        detailList: [
          {
            id: 3001,
            historyId: historyId,
            type: HistoryDetailType.Question,
            contentType: HistoryContentType.Ai,
            content: '查询库存分布',
            isLike: null
          },
          {
            id: 3002,
            historyId: historyId,
            type: HistoryDetailType.Answer,
            contentType: HistoryContentType.Ai,
            content: '{"historyId":1002,"hasTool":false,"name":null,"msg":"当前库存主要集中在一号仓和二号仓，可继续按仓库细看。","arguments":null}',
            isLike: null
          }
        ]
      }
    }

    return {
      id: historyId,
      name: '查看一月销售额',
      createTime: '2026-01-31 10:00:00',
      updateTime: '2026-01-31 10:01:00',
      detailList: [
        {
          id: 2001,
          historyId: historyId,
          type: HistoryDetailType.Question,
          contentType: HistoryContentType.Ai,
          content: '查看一月销售额',
          isLike: null
        },
        {
          id: 2002,
          historyId: historyId,
          type: HistoryDetailType.Answer,
          contentType: HistoryContentType.Chart,
          content: '{"funcType":"querySalesGroupByMonth","chartCommonVoList":[{"bizId":"2026-01","name":"2026-01","value":128800.5}],"accountAgeGroupVoList":null}',
          isLike: this.liked.get(2002) ?? '1'
        }
      ]
    }
  }

  async sendFunctionMessage(text: string, historyId?: number | null): Promise<FunctionModel> {
    if (text.indexOf('fallback') >= 0 || text.indexOf('测试降级') >= 0) {
      return {
        historyId: historyId ?? 1001,
        hasTool: true,
        name: FunctionName.QuerySalesGroupByMonth,
        msg: null,
        arguments: {
          kind: FunctionArgumentKind.Basic,
          basic: {}
        }
      }
    }

    if (text.indexOf('销售') >= 0 && text.indexOf('本月') < 0 && text.indexOf('一月') < 0) {
      return {
        historyId: historyId ?? null,
        hasTool: true,
        name: FunctionName.QuerySalesGroupByMonth,
        msg: '请选择查询时间范围',
        arguments: {
          kind: FunctionArgumentKind.TimeRange,
          timeRange: {
            startDate: null,
            endDate: null
          }
        }
      }
    }

    if (text.indexOf('图表') >= 0 || text.indexOf('销售') >= 0 || text.indexOf('本月') >= 0) {
      return {
        historyId: historyId ?? 1001,
        hasTool: true,
        name: FunctionName.QuerySalesGroupByMonth,
        msg: null,
        arguments: {
          kind: FunctionArgumentKind.TimeRange,
          timeRange: {
            startDate: '2026-05-01',
            endDate: '2026-05-31'
          }
        }
      }
    }

    return {
      historyId: historyId ?? null,
      hasTool: false,
      name: null,
      msg: null,
      arguments: null
    }
  }

  async loadChartData(name: FunctionName, historyId: number, argumentsValue: FunctionArguments): Promise<HistoryChartDetail> {
    if (argumentsValue.kind !== FunctionArgumentKind.TimeRange) {
      return {
        funcType: name,
        chartCommonVoList: new Array<ChartCommonItem>(),
        accountAgeGroupVoList: null
      }
    }

    return {
      funcType: name,
      chartCommonVoList: [
        { bizId: '2026-05', name: '2026-05', value: 128000.0 },
        { bizId: '2026-04', name: '2026-04', value: 96000.0 }
      ],
      accountAgeGroupVoList: null
    }
  }

  async sendLikeFeedback(historyDetailId: number, like: string): Promise<void> {
    this.liked.set(historyDetailId, like)
  }

  async streamMessage(text: string): Promise<Array<string>> {
    return [
      '您好，',
      '这是基于 mock 数据生成的经营分析结果。',
      ' 当前链路已支持流式增量展示。'
    ]
  }
}

export class LoadTemplateUseCase {
  private repository: AIChatRepository

  constructor(repository: AIChatRepository) {
    this.repository = repository
  }

  async execute(): Promise<Array<string>> {
    let template = await this.repository.loadTemplate()
    return template.questions
  }
}

export class LoadHistoryDetailUseCase {
  private repository: AIChatRepository

  constructor(repository: AIChatRepository) {
    this.repository = repository
  }

  async execute(historyId: number): Promise<Array<ConversationMessage>> {
    let record = await this.repository.loadHistoryDetail(historyId)
    return mapHistoryDetailsToMessages(record.detailList ?? new Array<HistoryDetail>())
  }
}

export class SendFunctionMessageUseCase {
  private repository: AIChatRepository

  constructor(repository: AIChatRepository) {
    this.repository = repository
  }

  async execute(text: string, historyId?: number | null): Promise<SendFunctionResult> {
    let model = await this.repository.sendFunctionMessage(text, historyId)
    if (model.hasTool !== true) {
      return { kind: SendFunctionResultKind.Failure, message: model.msg ?? null }
    }
    if (model.name === null || model.name === undefined || model.arguments === null || model.arguments === undefined) {
      return { kind: SendFunctionResultKind.Failure, message: model.msg ?? null }
    }
    if (model.arguments.kind === FunctionArgumentKind.TimeRange) {
      let query = model.arguments.timeRange
      if (query === null || query === undefined || query.startDate === null || query.startDate === undefined) {
        return {
          kind: SendFunctionResultKind.Intent,
          text: '请选择查询时间范围',
          intentType: AIChatIntentType.Time
        }
      }
    }
    if (model.arguments.kind === FunctionArgumentKind.PerformanceType) {
      return {
        kind: SendFunctionResultKind.Intent,
        text: '请选择分析指标',
        intentType: AIChatIntentType.Index
      }
    }
    if (model.historyId === null || model.historyId === undefined) {
      return { kind: SendFunctionResultKind.Failure, message: model.msg ?? null }
    }
    return {
      kind: SendFunctionResultKind.ChartRequest,
      name: model.name,
      historyId: model.historyId,
      argumentsValue: model.arguments
    }
  }
}

export class LoadChartDataUseCase {
  private repository: AIChatRepository

  constructor(repository: AIChatRepository) {
    this.repository = repository
  }

  async execute(name: FunctionName, historyId: number, argumentsValue: FunctionArguments): Promise<LoadChartResult> {
    let detail = await this.repository.loadChartData(name, historyId, argumentsValue)
    let payload = mapChartPayload(detail)
    if (payload.series.length === 0) {
      return { kind: LoadChartResultKind.Failure, message: payload.emptyMessage ?? null }
    }
    return { kind: LoadChartResultKind.Chart, payload: payload }
  }
}

export class SendLikeFeedbackUseCase {
  private repository: AIChatRepository

  constructor(repository: AIChatRepository) {
    this.repository = repository
  }

  async execute(historyDetailId: number, like: string): Promise<boolean> {
    await this.repository.sendLikeFeedback(historyDetailId, like)
    return true
  }
}

export class StreamAIResponseUseCase {
  private repository: AIChatRepository

  constructor(repository: AIChatRepository) {
    this.repository = repository
  }

  async execute(text: string): Promise<Array<string>> {
    return this.repository.streamMessage(text)
  }
}

export function makeFallbackChartPayload(functionName?: FunctionName | null): ChartPayload {
  return {
    functionName: functionName ?? null,
    unit: ChartUnit.Currency,
    series: new Array<ChartSeries>(),
    emptyMessage: '数据分析还在测试阶段，很快就能上线，敬请期待！'
  }
}
