import {
  AccountSession,
  AIHomeCommand,
  ChartCommonItem,
  ChartPayload,
  ChartSeries,
  ChartUnit,
  ConversationContentKind,
  ConversationMessage,
  ConversationRole,
  FeedbackState,
  FunctionName,
  HistoryChartDetail,
  HistoryContentType,
  HistoryDetail,
  HistoryDetailType,
  TemplateQuestionSet,
  functionNameFromRawValue
} from '../generated/ContractModels'

export interface ApiEnvelope<T> {
  code: number
  msg?: string | null
  data: T
  trace?: string | null
  tid?: string | null
}

export interface LoginPayload {
  accessToken?: string | null
  refreshToken?: string | null
  access_token?: string | null
  refresh_token?: string | null
  orgId?: number | null
  username?: string | null
}

export interface LoginMappingOutput {
  session: AccountSession
  routeIntent: AIHomeCommand
}

export function mapLoginResponse(response: ApiEnvelope<LoginPayload>): LoginMappingOutput {
  let data = response.data
  return {
    session: {
      accessToken: data.accessToken ?? data.access_token ?? null,
      refreshToken: data.refreshToken ?? data.refresh_token ?? null,
      orgId: data.orgId ?? null,
      username: data.username ?? null,
      isLogin: response.code === 200
    },
    routeIntent: AIHomeCommand.OpenAIHome
  }
}

export function normalizeTemplateQuestionSet(data: string | TemplateQuestionSet): TemplateQuestionSet {
  if (typeof data === 'string') {
    return JSON.parse(data) as TemplateQuestionSet
  }
  return data
}

export function mapHistoryDetailsToMessages(details: Array<HistoryDetail>): Array<ConversationMessage> {
  return details.map((detail: HistoryDetail): ConversationMessage => {
    if (detail.type === HistoryDetailType.Question) {
      return {
        id: `${detail.id ?? 0}`,
        role: ConversationRole.User,
        contentKind: ConversationContentKind.Text,
        text: detail.content ?? null,
        feedback: FeedbackState.None,
        historyDetailId: detail.id ?? null
      }
    }

    if (detail.contentType === HistoryContentType.Chart) {
      let chartDetail = JSON.parse(detail.content ?? '{}') as RawHistoryChartDetail
      let chartPayload = mapRawChartPayload(chartDetail)
      return {
        id: `${detail.id ?? 0}`,
        role: ConversationRole.Assistant,
        contentKind: ConversationContentKind.Chart,
        chartPayload: chartPayload,
        feedback: feedbackFromLike(detail.isLike),
        historyDetailId: detail.id ?? null,
        functionName: chartPayload.functionName ?? null
      }
    }

    let functionModel = JSON.parse(detail.content ?? '{}') as FunctionModelTextPayload
    return {
      id: `${detail.id ?? 0}`,
      role: ConversationRole.Assistant,
      contentKind: ConversationContentKind.Text,
      text: functionModel.msg ?? detail.content ?? null,
      feedback: feedbackFromLike(detail.isLike),
      historyDetailId: detail.id ?? null
    }
  })
}

export function mapChartPayload(detail: HistoryChartDetail): ChartPayload {
  let functionName = detail.funcType ?? null
  let series = (detail.chartCommonVoList ?? []).map((item: ChartCommonItem): ChartSeries => {
    let label = item.name ?? ''
    return {
      xAxis: label,
      labels: [label],
      values: [item.value ?? 0]
    }
  })

  return {
    functionName: functionName,
    unit: chartUnitForFunctionName(functionName),
    series: series,
    emptyMessage: series.length === 0 ? '数据分析还在测试阶段，很快就能上线，敬请期待！' : null
  }
}

export function mapRawChartPayload(raw: RawHistoryChartDetail): ChartPayload {
  return mapChartPayload({
    funcType: functionNameFromRawValue(raw.funcType),
    chartCommonVoList: raw.chartCommonVoList ?? null,
    accountAgeGroupVoList: null
  })
}

interface FunctionModelTextPayload {
  msg?: string | null
}

export interface RawHistoryChartDetail {
  funcType?: string | null
  chartCommonVoList?: Array<ChartCommonItem> | null
}

function feedbackFromLike(value?: string | null): FeedbackState {
  if (value === '1') {
    return FeedbackState.Liked
  }
  if (value === '0') {
    return FeedbackState.Disliked
  }
  if (value === null || value === undefined) {
    return FeedbackState.None
  }
  return FeedbackState.Unknown
}

function chartUnitForFunctionName(name?: FunctionName | null): ChartUnit {
  if (name === FunctionName.QueryStockGroupByOrg || name === FunctionName.QueryStockGroupByWarehouse) {
    return ChartUnit.Ton
  }
  return ChartUnit.Currency
}
