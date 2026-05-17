'use client';

import type { ConversationMessage, FunctionModel } from '@/contracts/generated/models';
import { loadHistoryDetail } from '@/features/history/history-api';
import { useQuery } from '@tanstack/react-query';
import { analyzeFunction, loadChartData, sendLikeFeedback, streamAIResponse } from './ai-chat-api';
import {
  createAssistantTextMessage,
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

      await appendAssistantResponse({
        model: functionModel,
        question,
        appendMessages: (assistantMessages) => {
          setDraftMessages((current) => [...current, ...assistantMessages]);
        },
        updateMessage: (messageId, text) => {
          setDraftMessages((current) =>
            current.map((message) => (message.id === messageId ? { ...message, text } : message)),
          );
        },
      });
    } catch (error) {
      setErrorMessage(error instanceof Error ? error.message : '发送失败，请稍后重试');
    } finally {
      setSending(false);
    }
  }, [activeHistoryId, input, isSending, messages]);

  const sendFeedback = useCallback(
    async (messageId: string, historyDetailId: number, feedback: 'liked' | 'disliked') => {
      const previousMessages = messages;
      setDraftMessages(
        messages.map((message) =>
          message.id === messageId ? { ...message, feedback } : message,
        ),
      );

      try {
        await sendLikeFeedback({
          historyDetailId,
          like: feedback === 'liked' ? '1' : '0',
        });
      } catch (error) {
        setDraftMessages(previousMessages);
        setErrorMessage(error instanceof Error ? error.message : '反馈提交失败，请稍后重试');
      }
    },
    [messages],
  );

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
      sendFeedback,
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
      sendFeedback,
    ],
  );
}

async function appendAssistantResponse({
  model,
  question,
  appendMessages,
  updateMessage,
}: {
  model: FunctionModel;
  question: string;
  appendMessages: (messages: ConversationMessage[]) => void;
  updateMessage: (messageId: string, text: string) => void;
}) {
  if (!model.hasTool) {
    const messageId = `assistant-stream-${Date.now()}`;
    let streamedText = '';
    appendMessages([createAssistantTextMessage(messageId, model.msg ?? '')]);

    try {
      for await (const chunk of streamAIResponse(question)) {
        streamedText += chunk;
        updateMessage(messageId, streamedText);
      }
      if (!streamedText && model.msg) {
        updateMessage(messageId, model.msg);
      }
    } catch {
      updateMessage(messageId, streamedText || model.msg || '响应生成失败，请稍后重试。');
    }
    return;
  }

  if (!model.name || !model.historyId || model.name === 'queryPerformanceType') {
    appendMessages([mapFunctionModelToMessage(model)]);
    return;
  }

  try {
    const chartDetail = await loadChartData(model.name, model.historyId);
    appendMessages([
      mapChartDetailToMessage({
        ...chartDetail,
        historyDetailId: chartDetail.historyDetailId ?? model.historyId,
        funcType: chartDetail.funcType ?? model.name,
      }),
    ]);
  } catch {
    appendMessages([
      {
        ...mapFunctionModelToMessage(model),
        contentKind: 'text',
        text: '图表数据加载失败，请稍后重试。',
      },
    ]);
  }
}
