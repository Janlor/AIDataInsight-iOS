'use client';

import type { ConversationMessage } from '@/contracts/generated/models';
import { Loader2, SendHorizonal, ThumbsDown, ThumbsUp } from 'lucide-react';
import { FormEvent, Suspense } from 'react';
import { useSearchParams } from 'next/navigation';
import { PageHeader } from '@/components/page-header';
import { ChartMessage } from '@/features/ai-chat/chart-message';
import { useAIChatController } from '@/features/ai-chat/use-ai-chat-controller';
import { useTemplateQuestions } from '@/features/ai-chat/use-template-questions';

export default function AIPage() {
  return (
    <Suspense fallback={<div className="text-sm text-label-secondary">正在加载 AI 工作台...</div>}>
      <AIPageContent />
    </Suspense>
  );
}

function AIPageContent() {
  const searchParams = useSearchParams();
  const historyId = parseHistoryId(searchParams.get('historyId'));

  return <AIWorkspace key={historyId ?? 'new'} historyId={historyId} />;
}

function AIWorkspace({ historyId }: { historyId: number | null }) {
  const templateQuery = useTemplateQuestions();
  const chat = useAIChatController(historyId);
  const templateQuestions = templateQuery.data ?? [
    '本月销售额按月份汇总',
    '库存按仓库分布',
    '应收账款账龄分析',
  ];

  function onSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    void chat.send();
  }

  return (
    <>
      <PageHeader
        title="AI 工作台"
        description="第一版已接入 Web shell 和会话守卫，后续在这里接入模板、流式响应和图表结果。"
      />

      {chat.errorMessage ? (
        <div className="mb-4 rounded-control border border-red-200 bg-red-50 px-3 py-2 text-sm text-red-700">
          {chat.errorMessage}
        </div>
      ) : null}

      <div className="grid gap-6 xl:grid-cols-[1fr_320px]">
        <section className="flex min-h-[calc(100vh-11rem)] flex-col rounded-lg border border-separator bg-white shadow-sm">
          <div className="flex-1 space-y-4 overflow-y-auto p-4 sm:p-6">
            {chat.isRestoringHistory ? (
              <div className="flex items-center justify-center gap-2 py-10 text-sm text-label-secondary">
                <Loader2 aria-hidden="true" className="animate-spin" size={18} />
                正在恢复历史会话...
              </div>
            ) : null}
            {chat.messages.map((message) => (
              <div
                key={message.id}
                className={message.role === 'user' ? 'flex justify-end' : 'flex justify-start'}
              >
                <div
                  className={[
                    'max-w-[min(680px,85%)] rounded-lg px-4 py-3 text-sm leading-6',
                    message.role === 'user'
                      ? 'bg-accent-primary text-white'
                      : 'border border-separator bg-surface-secondary text-label-primary',
                  ].join(' ')}
                >
                  <MessageContent
                    message={message}
                    onFeedback={(feedback) => {
                      if (message.historyDetailId) {
                        void chat.sendFeedback(message.id, message.historyDetailId, feedback);
                      }
                    }}
                  />
                </div>
              </div>
            ))}
            {chat.isSending ? (
              <div className="flex justify-start">
                <div className="flex items-center gap-2 rounded-lg border border-separator bg-surface-secondary px-4 py-3 text-sm text-label-secondary">
                  <Loader2 aria-hidden="true" className="animate-spin" size={16} />
                  正在分析...
                </div>
              </div>
            ) : null}
          </div>

          <form className="border-t border-separator p-3 sm:p-4" onSubmit={onSubmit}>
            <div className="flex items-end gap-2 rounded-lg border border-separator bg-white p-2">
              <textarea
                className="min-h-11 flex-1 resize-none border-0 bg-transparent px-2 py-2 text-sm outline-none"
                rows={1}
                value={chat.input}
                onChange={(event) => chat.setInput(event.target.value)}
                placeholder="输入你想分析的问题"
              />
              <button
                aria-label="发送"
                className="flex h-10 w-10 shrink-0 items-center justify-center rounded-control bg-accent-primary text-white transition hover:bg-blue-700 disabled:opacity-50"
                type="submit"
                disabled={!chat.canSend}
              >
                {chat.isSending ? (
                  <Loader2 aria-hidden="true" className="animate-spin" size={18} />
                ) : (
                  <SendHorizonal aria-hidden="true" size={18} />
                )}
              </button>
            </div>
          </form>
        </section>

        <aside className="space-y-3">
          <h2 className="text-sm font-semibold text-label-primary">推荐问题</h2>
          {templateQuery.isLoading ? (
            <div className="rounded-lg border border-separator bg-white p-4 text-sm text-label-secondary shadow-sm">
              正在加载模板...
            </div>
          ) : null}
          {templateQuery.isError ? (
            <div className="rounded-lg border border-amber-200 bg-amber-50 p-4 text-sm text-amber-800">
              模板加载失败，已显示默认问题。
            </div>
          ) : null}
          {templateQuestions.map((question) => (
            <button
              key={question}
              className="block w-full rounded-lg border border-separator bg-white p-4 text-left text-sm text-label-primary shadow-sm transition hover:border-blue-200 hover:bg-blue-50"
              type="button"
              onClick={() => chat.setInput(question)}
            >
              {question}
            </button>
          ))}
        </aside>
      </div>
    </>
  );
}

function MessageContent({
  message,
  onFeedback,
}: {
  message: ConversationMessage;
  onFeedback: (feedback: 'liked' | 'disliked') => void;
}) {
  if (message.contentKind === 'chart') {
    return (
      <div>
        <p className="font-medium">图表结果</p>
        <ChartMessage payload={message.chartPayload} />
        <FeedbackActions message={message} onFeedback={onFeedback} />
      </div>
    );
  }

  if (message.contentKind === 'intent') {
    return (
      <div>
        <p>{message.text ?? '已识别分析意图。'}</p>
        {message.functionName ? (
          <p className="mt-2 text-xs text-label-tertiary">Function: {message.functionName}</p>
        ) : null}
        <FeedbackActions message={message} onFeedback={onFeedback} />
      </div>
    );
  }

  return (
    <div>
      <p>{message.text ?? ''}</p>
      <FeedbackActions message={message} onFeedback={onFeedback} />
    </div>
  );
}

function FeedbackActions({
  message,
  onFeedback,
}: {
  message: ConversationMessage;
  onFeedback: (feedback: 'liked' | 'disliked') => void;
}) {
  if (message.role !== 'assistant' || !message.historyDetailId) {
    return null;
  }

  return (
    <div className="mt-3 flex items-center gap-2">
      <button
        aria-label="喜欢"
        className={[
          'flex h-8 w-8 items-center justify-center rounded-control border transition',
          message.feedback === 'liked'
            ? 'border-accent-primary bg-blue-50 text-accent-primary'
            : 'border-separator bg-white text-label-tertiary hover:text-label-primary',
        ].join(' ')}
        type="button"
        onClick={() => onFeedback('liked')}
      >
        <ThumbsUp aria-hidden="true" size={15} />
      </button>
      <button
        aria-label="不喜欢"
        className={[
          'flex h-8 w-8 items-center justify-center rounded-control border transition',
          message.feedback === 'disliked'
            ? 'border-mark bg-red-50 text-mark'
            : 'border-separator bg-white text-label-tertiary hover:text-label-primary',
        ].join(' ')}
        type="button"
        onClick={() => onFeedback('disliked')}
      >
        <ThumbsDown aria-hidden="true" size={15} />
      </button>
    </div>
  );
}

function parseHistoryId(value: string | null): number | null {
  if (!value) {
    return null;
  }
  const parsed = Number(value);
  return Number.isInteger(parsed) && parsed > 0 ? parsed : null;
}
