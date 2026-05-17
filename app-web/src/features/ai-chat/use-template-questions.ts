'use client';

import { useQuery } from '@tanstack/react-query';
import { loadTemplateQuestions } from './ai-chat-api';

export function useTemplateQuestions() {
  return useQuery({
    queryKey: ['ai-chat', 'template-questions'],
    queryFn: loadTemplateQuestions,
  });
}
