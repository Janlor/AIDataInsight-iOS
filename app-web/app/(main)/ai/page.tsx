'use client';

import { SendHorizonal } from 'lucide-react';
import { FormEvent, useState } from 'react';
import { PageHeader } from '@/components/page-header';

const templateQuestions = [
  '本月销售额按月份汇总',
  '库存按仓库分布',
  '应收账款账龄分析',
];

export default function AIPage() {
  const [messages, setMessages] = useState([
    {
      role: 'assistant',
      text: '你好，我可以帮你查询销售、采购、库存、应收账款等经营数据。',
    },
  ]);
  const [input, setInput] = useState('');

  function onSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const text = input.trim();
    if (!text) return;
    setMessages((current) => [
      ...current,
      { role: 'user', text },
      { role: 'assistant', text: 'AI Chat 网络用例将在下一阶段接入，目前已完成页面闭环和输入状态。' },
    ]);
    setInput('');
  }

  return (
    <>
      <PageHeader
        title="AI 工作台"
        description="第一版已接入 Web shell 和会话守卫，后续在这里接入模板、流式响应和图表结果。"
      />

      <div className="grid gap-6 xl:grid-cols-[1fr_320px]">
        <section className="flex min-h-[calc(100vh-11rem)] flex-col rounded-lg border border-separator bg-white shadow-sm">
          <div className="flex-1 space-y-4 overflow-y-auto p-4 sm:p-6">
            {messages.map((message, index) => (
              <div
                key={`${message.role}-${index}`}
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
                  {message.text}
                </div>
              </div>
            ))}
          </div>

          <form className="border-t border-separator p-3 sm:p-4" onSubmit={onSubmit}>
            <div className="flex items-end gap-2 rounded-lg border border-separator bg-white p-2">
              <textarea
                className="min-h-11 flex-1 resize-none border-0 bg-transparent px-2 py-2 text-sm outline-none"
                rows={1}
                value={input}
                onChange={(event) => setInput(event.target.value)}
                placeholder="输入你想分析的问题"
              />
              <button
                aria-label="发送"
                className="flex h-10 w-10 shrink-0 items-center justify-center rounded-control bg-accent-primary text-white transition hover:bg-blue-700 disabled:opacity-50"
                type="submit"
                disabled={!input.trim()}
              >
                <SendHorizonal aria-hidden="true" size={18} />
              </button>
            </div>
          </form>
        </section>

        <aside className="space-y-3">
          <h2 className="text-sm font-semibold text-label-primary">推荐问题</h2>
          {templateQuestions.map((question) => (
            <button
              key={question}
              className="block w-full rounded-lg border border-separator bg-white p-4 text-left text-sm text-label-primary shadow-sm transition hover:border-blue-200 hover:bg-blue-50"
              type="button"
              onClick={() => setInput(question)}
            >
              {question}
            </button>
          ))}
        </aside>
      </div>
    </>
  );
}
