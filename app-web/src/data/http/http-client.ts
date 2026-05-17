import { runtimeConfig } from '@/lib/env';
import { AppError } from '@/domain/errors';

export interface ResponseEnvelope<T> {
  msg?: string | null;
  code: number;
  data?: T | null;
  trace?: string | null;
  tid?: string | null;
}

export type HttpMethod = 'GET' | 'POST' | 'PUT' | 'PATCH' | 'DELETE';

export interface RequestOptions {
  method?: HttpMethod;
  query?: Record<string, string | number | boolean | null | undefined>;
  body?: unknown;
  skipAuth?: boolean;
  skipRefresh?: boolean;
  signal?: AbortSignal;
}

export interface HttpAuthBridge {
  getAccessToken(): string | null;
  refreshToken(): Promise<boolean>;
  clearSession(): void;
}

let authBridge: HttpAuthBridge | null = null;
let refreshTask: Promise<boolean> | null = null;

export function configureHttpAuthBridge(bridge: HttpAuthBridge) {
  authBridge = bridge;
}

export async function request<T>(path: string, options: RequestOptions = {}): Promise<T> {
  return requestInternal<T>(path, options, false);
}

async function requestInternal<T>(
  path: string,
  options: RequestOptions,
  hasRetriedAfterRefresh: boolean,
): Promise<T> {
  const response = await fetch(buildUrl(path, options.query), {
    method: options.method ?? 'POST',
    headers: buildHeaders(options),
    body: options.body == null ? undefined : JSON.stringify(options.body),
    signal: options.signal,
  });

  if (!response.ok) {
    throw new AppError('unknown', `HTTP ${response.status}`);
  }

  const envelope = await parseEnvelope<T>(response);

  if (envelope.code === 200) {
    return envelope.data as T;
  }

  if (envelope.code === 402 && !options.skipRefresh && !hasRetriedAfterRefresh) {
    const refreshed = await refreshAccessToken();
    if (refreshed) {
      return requestInternal<T>(path, options, true);
    }
  }

  if (envelope.code === 401 || envelope.code === 402) {
    authBridge?.clearSession();
  }

  throw new AppError('server', envelope.msg ?? '服务端返回错误', {
    code: envelope.code,
    trace: envelope.trace,
    tid: envelope.tid,
  });
}

async function refreshAccessToken(): Promise<boolean> {
  if (!authBridge) {
    return false;
  }

  refreshTask ??= authBridge
    .refreshToken()
    .catch(() => false)
    .finally(() => {
      refreshTask = null;
    });

  return refreshTask;
}

function buildUrl(path: string, query?: RequestOptions['query']) {
  const url = new URL(path, runtimeConfig.apiBaseUrl);
  Object.entries(query ?? {}).forEach(([key, value]) => {
    if (value !== null && value !== undefined) {
      url.searchParams.set(key, String(value));
    }
  });
  return url;
}

function buildHeaders(options: RequestOptions): HeadersInit {
  const headers: Record<string, string> = {
    Accept: 'application/json',
  };

  if (options.body != null) {
    headers['Content-Type'] = 'application/json';
  }

  const token = options.skipAuth ? null : authBridge?.getAccessToken();
  if (token) {
    headers.Authorization = `Bearer ${token}`;
  }

  return headers;
}

async function parseEnvelope<T>(response: Response): Promise<ResponseEnvelope<T>> {
  try {
    const json = (await response.json()) as Partial<ResponseEnvelope<T>>;
    if (typeof json.code !== 'number') {
      throw new AppError('dataFormat', '响应缺少业务 code');
    }
    return {
      code: json.code,
      msg: json.msg ?? null,
      data: json.data ?? null,
      trace: json.trace ?? null,
      tid: json.tid ?? null,
    };
  } catch (error) {
    if (error instanceof AppError) {
      throw error;
    }
    throw new AppError('dataFormat', '响应格式不正确');
  }
}
