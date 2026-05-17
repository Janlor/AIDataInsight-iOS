import type {
  FunctionModel,
  FunctionName,
  HistoryChartDetail,
  TemplateQuestionSet,
} from '@/contracts/generated/models';
import { request } from '@/data/http/http-client';
import { normalizeTemplateQuestions } from './ai-chat-mappers';
import type { FunctionAnalysisInput, LikeFeedbackInput } from './ai-chat-types';

type TemplateResponse = TemplateQuestionSet | string | null;

export async function loadTemplateQuestions() {
  const payload = await request<TemplateResponse>('/chat/template', {
    method: 'GET',
  });
  return normalizeTemplateQuestions(payload);
}

export function analyzeFunction(input: FunctionAnalysisInput) {
  return request<FunctionModel>('/chat/function', {
    method: 'GET',
    query: {
      question: input.question,
      historyId: input.historyId ?? undefined,
    },
  });
}

export function loadChartData(functionName: FunctionName, historyId: number) {
  return request<HistoryChartDetail>(`/chart/${functionName}`, {
    method: 'GET',
    query: { historyId },
  });
}

export function sendLikeFeedback(input: LikeFeedbackInput) {
  return request<null>('/history/like', {
    method: 'POST',
    body: input,
  });
}
