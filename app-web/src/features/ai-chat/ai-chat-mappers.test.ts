import { describe, expect, it } from 'vitest';
import templateFixture from '../../../../docs/cross-platform/contracts/fixtures/api/chat-template-string-payload.json';
import historyChartFixture from '../../../../docs/cross-platform/contracts/fixtures/history/history-detail-with-chart.json';
import historyTextFixture from '../../../../docs/cross-platform/contracts/fixtures/history/history-detail-with-ai-text.json';
import type { HistoryRecord } from '@/contracts/generated/models';
import { mapHistoryRecordToMessages, normalizeTemplateQuestions } from './ai-chat-mappers';

describe('ai-chat mappers', () => {
  it('normalizes embedded JSON string template payloads from the contract fixture', () => {
    const questions = normalizeTemplateQuestions(templateFixture.response.data);

    expect(questions).toEqual(templateFixture.expected.templateQuestions);
  });

  it('maps text history detail into conversation messages', () => {
    const messages = mapHistoryRecordToMessages(historyTextFixture.response.data as HistoryRecord);

    expect(messages).toMatchObject(historyTextFixture.expected.messages);
  });

  it('maps chart history detail into a chart conversation message', () => {
    const messages = mapHistoryRecordToMessages(historyChartFixture.response.data as HistoryRecord);
    const chartMessage = messages[1];
    const expectedChartMessage = historyChartFixture.expected.messages[1];

    expect(chartMessage).toBeDefined();
    expect(expectedChartMessage).toBeDefined();

    expect(chartMessage).toMatchObject({
      role: 'assistant',
      contentKind: 'chart',
      feedback: 'liked',
      historyDetailId: 1002,
      functionName: 'querySalesGroupByMonth',
    });
    expect(chartMessage?.chartPayload?.unit).toBe(expectedChartMessage?.chartPayload?.unit);
    expect(chartMessage?.chartPayload?.series).toHaveLength(
      expectedChartMessage?.chartPayload?.seriesCount ?? 0,
    );
  });
});
