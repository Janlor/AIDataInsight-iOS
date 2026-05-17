import type { ConversationMessage } from '@/contracts/generated/models';

export interface AIChatViewState {
  historyId: number | null;
  messages: ConversationMessage[];
  templateQuestions: string[];
  inputText: string;
  isLoadingTemplate: boolean;
  isSending: boolean;
  isStreaming: boolean;
  errorMessage: string | null;
  canSend: boolean;
  canClear: boolean;
  scrollToBottom: boolean;
}

export interface FunctionAnalysisInput {
  question: string;
  historyId?: number | null;
}

export interface LikeFeedbackInput {
  historyDetailId: number;
  like: '1' | '0';
}
