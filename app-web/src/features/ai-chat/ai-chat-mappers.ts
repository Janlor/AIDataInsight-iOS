import type {
  ChartPayload,
  ChartSeries,
  ConversationMessage,
  FunctionModel,
  FunctionName,
  HistoryChartDetail,
  HistoryDetail,
  HistoryRecord,
  TemplateQuestionSet,
} from '@/contracts/generated/models';

export function normalizeTemplateQuestions(payload: TemplateQuestionSet | string | null | undefined): string[] {
  if (!payload) {
    return [];
  }

  if (typeof payload === 'string') {
    return normalizeTemplateQuestions(parseJson<TemplateQuestionSet>(payload));
  }

  return Array.isArray(payload.questions) ? payload.questions.filter(Boolean) : [];
}

export function mapHistoryRecordToMessages(record: HistoryRecord | null | undefined): ConversationMessage[] {
  return (record?.detailList ?? []).flatMap((detail, index) => {
    const message = mapHistoryDetailToMessage(detail, index);
    return message ? [message] : [];
  });
}

export function mapFunctionModelToMessage(model: FunctionModel, fallbackId = 'assistant-current'): ConversationMessage {
  return {
    id: buildMessageId(fallbackId, model.historyId),
    role: 'assistant',
    contentKind: model.hasTool && model.name ? 'intent' : 'text',
    text: model.msg ?? null,
    feedback: 'none',
    historyDetailId: null,
    functionName: model.name ?? null,
  };
}

export function createUserMessage(text: string): ConversationMessage {
  return {
    id: `user-${Date.now()}`,
    role: 'user',
    contentKind: 'text',
    text,
    feedback: 'none',
  };
}

export function createWelcomeMessage(): ConversationMessage {
  return {
    id: 'welcome',
    role: 'assistant',
    contentKind: 'welcome',
    text: '你好，我可以帮你查询销售、采购、库存、应收账款等经营数据。',
    feedback: 'none',
  };
}

export function mapChartDetailToMessage(
  detail: HistoryChartDetail,
  fallbackId = 'chart-current',
): ConversationMessage {
  return {
    id: buildMessageId(fallbackId, detail.historyDetailId),
    role: 'assistant',
    contentKind: 'chart',
    text: null,
    chartPayload: mapChartDetailToPayload(detail),
    feedback: 'none',
    historyDetailId: detail.historyDetailId ?? null,
    functionName: detail.funcType ?? null,
  };
}

export function mapChartDetailToPayload(detail: HistoryChartDetail): ChartPayload {
  const functionName = detail.funcType ?? null;
  const commonItems = detail.chartCommonVoList ?? [];
  const accountAgeItems = detail.accountAgeGroupVoList ?? [];
  const series: ChartSeries[] = [];

  if (commonItems.length > 0) {
    series.push({
      xAxis: commonItems[0]?.name ?? commonItems[0]?.bizId ?? functionName ?? 'chart',
      labels: commonItems.map((item) => item.name ?? item.bizId ?? ''),
      values: commonItems.map((item) => item.value ?? 0),
    });
  }

  accountAgeItems.forEach((item) => {
    series.push({
      xAxis: item.name ?? 'accountAge',
      labels: item.labelList ?? [],
      values: item.valueList ?? [],
    });
  });

  return {
    functionName,
    unit: inferChartUnit(functionName),
    series,
    emptyMessage: series.length === 0 ? '暂无图表数据' : null,
  };
}

function mapHistoryDetailToMessage(
  detail: HistoryDetail,
  index: number,
): ConversationMessage | null {
  const id = buildMessageId(index, detail.id);
  const isUser = detail.type === '1';
  const isAssistant = detail.type === '2';

  if (isUser) {
    return {
      id,
      role: 'user',
      contentKind: 'text',
      text: detail.content ?? '',
      feedback: 'none',
      historyDetailId: detail.id ?? null,
    };
  }

  if (!isAssistant) {
    return null;
  }

  if (detail.contentType === '2') {
    const chartDetail = parseJson<HistoryChartDetail>(detail.content);
    if (!chartDetail) {
      return assistantTextMessage(id, detail, '图表数据解析失败');
    }
    const normalizedChartDetail = {
      ...chartDetail,
      historyDetailId: chartDetail.historyDetailId ?? detail.id ?? null,
    };
    return {
      id,
      role: 'assistant',
      contentKind: 'chart',
      text: null,
      chartPayload: mapChartDetailToPayload(normalizedChartDetail),
      feedback: mapFeedback(detail.isLike),
      historyDetailId: detail.id ?? null,
      functionName: normalizedChartDetail.funcType ?? null,
    };
  }

  const model = parseJson<FunctionModel>(detail.content);
  if (model) {
    return {
      ...mapFunctionModelToMessage(model, id),
      id,
      contentKind: model.hasTool && model.name ? 'intent' : 'text',
      feedback: mapFeedback(detail.isLike),
      historyDetailId: detail.id ?? null,
    };
  }

  return assistantTextMessage(id, detail, detail.content ?? '');
}

function assistantTextMessage(
  id: string,
  detail: HistoryDetail,
  text: string,
): ConversationMessage {
  return {
    id,
    role: 'assistant',
    contentKind: 'text',
    text,
    feedback: mapFeedback(detail.isLike),
    historyDetailId: detail.id ?? null,
  };
}

function mapFeedback(value: HistoryDetail['isLike']): ConversationMessage['feedback'] {
  if (value === '1') {
    return 'liked';
  }
  if (value === '0') {
    return 'disliked';
  }
  return 'none';
}

function inferChartUnit(functionName: FunctionName | null): ChartPayload['unit'] {
  if (functionName?.toLowerCase().includes('stock') || functionName?.toLowerCase().includes('inventory')) {
    return 'ton';
  }
  return 'currency';
}

function buildMessageId(prefix: string | number, id: number | null | undefined): string {
  return id == null ? `message-${prefix}` : String(id);
}

function parseJson<T>(value: string | null | undefined): T | null {
  if (!value) {
    return null;
  }
  try {
    return JSON.parse(value) as T;
  } catch {
    return null;
  }
}
