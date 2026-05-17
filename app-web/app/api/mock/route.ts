import { NextResponse } from 'next/server';

const endpoints = [
  'POST /api/mock/oauth2/login',
  'GET /api/mock/oauth2/refresh?refreshToken=mock-refresh-token',
  'GET /api/mock/oauth2/logout',
  'GET /api/mock/oauth2/getUserInfo',
  'GET /api/mock/chat/template',
  'GET /api/mock/chat/function?question=查看一月销售额',
  'GET /api/mock/stream?question=你好',
  'GET /api/mock/chart/querySalesGroupByMonth?historyId=123',
  'GET /api/mock/history/page?currentPage=1&pageSize=20',
  'GET /api/mock/history/detail?historyId=123',
  'POST /api/mock/history/like',
  'GET /api/mock/history/delete?historyId=123',
  'GET /api/mock/history/deleteAll',
];

export function GET() {
  return NextResponse.json({
    code: 200,
    msg: 'ok',
    data: {
      name: 'AIDataInsight Web local mock API',
      description: 'Local fixture API for offline development and Playwright E2E.',
      endpoints,
    },
    trace: null,
    tid: null,
  });
}
