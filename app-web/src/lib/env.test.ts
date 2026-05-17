import { describe, expect, it } from 'vitest';
import { resolveApiBaseUrl } from './env';

describe('resolveApiBaseUrl', () => {
  it('defaults mock environment to the shared Apifox mock host', () => {
    expect(resolveApiBaseUrl('mock')).toBe(
      'https://m1.apifoxmock.com/m1/3174267-1700689-default',
    );
  });

  it('defaults local environment to the local mock API', () => {
    expect(resolveApiBaseUrl('local')).toBe('http://localhost:3000/api/mock');
  });

  it('requires an explicit base URL for deployable environments', () => {
    expect(() => resolveApiBaseUrl('dev')).toThrow(/NEXT_PUBLIC_API_BASE_URL/);
  });

  it('uses explicit base URL for every environment', () => {
    expect(resolveApiBaseUrl('pre', 'https://pre.example.com')).toBe('https://pre.example.com');
  });
});
