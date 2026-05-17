import { mockApiEnvironment } from '@/contracts/generated/models';

export type AppEnv = 'dev' | 'pre' | 'prod' | 'mock';

export interface WebRuntimeConfig {
  appEnv: AppEnv;
  apiBaseUrl: string;
}

function readAppEnv(): AppEnv {
  const value = process.env.NEXT_PUBLIC_APP_ENV ?? process.env.APP_ENV ?? 'mock';
  if (value === 'dev' || value === 'pre' || value === 'prod' || value === 'mock') {
    return value;
  }
  return 'mock';
}

export const runtimeConfig: WebRuntimeConfig = {
  appEnv: readAppEnv(),
  apiBaseUrl: process.env.NEXT_PUBLIC_API_BASE_URL ?? mockApiEnvironment.baseUrl,
};
