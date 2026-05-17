'use client';

import type { ConversationMessage, FunctionModel } from '@/contracts/generated/models';
import { loadHistoryDetail } from '@/features/history/history-api';
import { useQuery } from '@tanstack/react-query';
import { analyzeFunction, loadChartData } from './ai-chat-api';
import {
  createUserMessage,
  createWelcomeMessage,
  mapChartDetailToMessage,
  mapFunctionModelToMessage,
  mapHistoryRecordToMessages,
} from './ai-chat-mappers';
import { useCallback, useMemo, useState } from 'react';

export function useAIChatController(historyId: number | null) {
  const [activeHistoryId, setActiveHistoryId] = useState<number | null>(historyId);
  const [draftMessages, setDraftMessages] = useState<ConversationMessage[]>([]);
  const [input, setInput] = useState('');
  const [isSending, setSending] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  const historyDetailQuery = useQuery({
    queryKey: ['history', 'detail', historyId],
    queryFn: () => loadHistoryDetail(historyId ?? 0),
    enabled: Boolean(historyId),
    select: mapHistoryRecordToMessages,
  });

  const restoredMessages = useMemo(() => historyDetailQuery.data ?? [], [historyDetailQuery.data]);
  const hasDraftMessages = draftMessages.length > 0;
  const messages = useMemo(
    () =>
      hasDraftMessages
        ? draftMessages
        : restoredMessages.length > 0
          ? restoredMessages
          : [createWelcomeMessage()],
    [draftMessages, hasDraftMessages, restoredMessages],
  );

  const canSend = input.trim().length > 0 && !isSending && !historyDetailQuery.isLoading;

  const send = useCallback(async () => {
    const question = input.trim();
    if (!question || isSending) {
      return;
    }

    const userMessage = createUserMessage(question);
    setDraftMessages((current) => [...(current.length > 0 ? current : messages), userMessage]);
    setInput('');
    setErrorMessage(null);
    setSending(true);

    try {
      const functionModel = await analyzeFunction({
        question,
        historyId: activeHistoryId,
      });
      setActiveHistoryId(functionModel.historyId ?? activeHistoryId);

      const assistantMessages = await buildAssistantMessages(functionModel);
      setDraftMessages((current) => [...current, ...assistantMessages]);
    } catch (error) {
      setErrorMessage(error instanceof Error ? error.message : '发送失败，请稍后重试');
    } finally {
      setSending(false);
    }
  }, [activeHistoryId, input, isSending, messages]);

  return useMemo(
    () => ({
      activeHistoryId,
      messages,
      input,
      setInput,
      isRestoringHistory: historyDetailQuery.isLoading,
      isSending,
      errorMessage:
        errorMessage ??
        (historyDetailQuery.isError ? '历史详情加载失败，请稍后重试' : null),
      canSend,
      send,
    }),
    [
      activeHistoryId,
      canSend,
      errorMessage,
      historyDetailQuery.isError,
      historyDetailQuery.isLoading,
      input,
      isSending,
      messages,
      send,
    ],
  );
}

async function buildAssistantMessages(model: FunctionModel): Promise<ConversationMessage[]> {
  if (!model.hasTool || !model.name || !model.historyId || model.name === 'queryPerformanceType') {
    return [mapFunctionModelToMessage(model)];
  }

  try {
    const chartDetail = await loadChartData(model.name, model.historyId);
    return [
      mapChartDetailToMessage({
        ...chartDetail,
        historyDetailId: chartDetail.historyDetailId ?? model.historyId,
        funcType: chartDetail.funcType ?? model.name,
      }),
    ];
  } catch {
    return [
      {
        ...mapFunctionModelToMessage(model),
        contentKind: 'text',
        text: '图表数据加载失败，请稍后重试。',
      },
    ];
  }
}
