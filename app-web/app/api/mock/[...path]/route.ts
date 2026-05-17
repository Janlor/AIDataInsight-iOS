import { NextResponse } from 'next/server';

type RouteContext = {
  params: Promise<{
    path?: string[];
  }>;
};

const ok = <T,>(data: T) =>
  NextResponse.json({
    code: 200,
    msg: 'ok',
    data,
    trace: null,
    tid: null,
  });

const empty = () => ok(null);

export async function GET(request: Request, context: RouteContext) {
  const path = await readPath(context);
  const url = new URL(request.url);

  if (path === 'oauth2/refresh') {
    return ok({
      accessToken: 'mock-access-token-refreshed',
      refreshToken: url.searchParams.get('refreshToken') ?? 'mock-refresh-token',
      orgId: 1,
    });
  }

  if (path === 'oauth2/logout') {
    return empty();
  }

  if (path === 'oauth2/getUserInfo') {
    return ok({
      id: 1,
      username: 'demo',
      nickname: 'Demo User',
      phone: null,
    });
  }

  if (path === 'chat/template') {
    return ok({
      questions: [
        '今年第三季度销售额大于2亿的公司有哪些？',
        '查看仓库中煤炭库存大于5万吨的公司。',
        '列出公司FHJK应收余额超过5000万的客户。',
        '钢材存货金额余额最多的公司？',
        '查看各公司账龄超过180天的金额。',
      ],
    });
  }

  if (path === 'chat/function') {
    const question = url.searchParams.get('question') ?? '';
    if (question.includes('你好') || question.toLowerCase().includes('hello')) {
      return ok({
        historyId: 456,
        hasTool: false,
        name: null,
        msg: '你好，我可以帮你分析经营数据。',
        arguments: null,
      });
    }

    return ok({
      historyId: 123,
      hasTool: true,
      name: 'querySalesGroupByMonth',
      msg: null,
      arguments: {
        kind: 'timeRange',
        value: {
          startDate: '2026-01-01',
          endDate: '2026-01-31',
          orgId: 1,
          customerName: null,
          goodsType: null,
          orderType: null,
          operator: null,
          value: null,
        },
      },
    });
  }

  if (path === 'stream') {
    return streamResponse(['你好，', '我可以帮你分析经营数据。']);
  }

  if (path === 'chart/querySalesGroupByMonth') {
    return ok({
      historyDetailId: 1002,
      funcType: 'querySalesGroupByMonth',
      chartCommonVoList: [
        { bizId: '2026-01', name: '2026-01', value: 128800.5 },
        { bizId: '2026-02', name: '2026-02', value: 156300.25 },
        { bizId: '2026-03', name: '2026-03', value: 183420.75 },
      ],
      accountAgeGroupVoList: null,
    });
  }

  if (path === 'history/page') {
    return ok({
      currentPage: 1,
      pageSize: 20,
      total: 3,
      pages: 1,
      cacheKey: 'mock-history-page',
      records: [
        {
          id: 456,
          name: '你好',
          createTime: '2026-05-17 09:30:00',
          updateTime: '2026-05-17 09:31:00',
        },
        {
          id: 123,
          name: '查看一月销售额',
          createTime: '2026-05-12 10:00:00',
          updateTime: '2026-05-12 10:01:00',
        },
        {
          id: 1003,
          name: '年度经营指标',
          createTime: '2025-12-30 08:00:00',
          updateTime: '2025-12-30 08:00:00',
        },
      ],
    });
  }

  if (path === 'history/detail') {
    const historyId = url.searchParams.get('historyId');
    return ok(historyId === '123' ? chartHistoryRecord : textHistoryRecord);
  }

  if (path === 'history/delete' || path === 'history/deleteAll') {
    return empty();
  }

  return notFound(path);
}

export async function POST(request: Request, context: RouteContext) {
  const path = await readPath(context);

  if (path === 'oauth2/login') {
    return ok({
      access_token: 'mock-access-token',
      refresh_token: 'mock-refresh-token',
      org_id: 1,
      expires_in: 1799,
      refresh_expires_in: 28799,
      client_id: 'ai-data-mobile-api',
      scope: 'ai-data-mobile-api',
      openid: null,
    });
  }

  if (path === 'history/like') {
    await request.json().catch(() => null);
    return empty();
  }

  return notFound(path);
}

async function readPath(context: RouteContext) {
  const params = await context.params;
  return (params.path ?? []).join('/');
}

function notFound(path: string) {
  return NextResponse.json(
    {
      code: 404,
      msg: `Mock route not found: ${path}`,
      data: null,
      trace: null,
      tid: null,
    },
    { status: 404 },
  );
}

function streamResponse(chunks: string[]) {
  const encoder = new TextEncoder();
  const stream = new ReadableStream({
    async start(controller) {
      for (const chunk of chunks) {
        controller.enqueue(encoder.encode(`data: ${chunk}\n\n`));
        await new Promise((resolve) => setTimeout(resolve, 80));
      }
      controller.enqueue(encoder.encode('data: [DONE]\n\n'));
      controller.close();
    },
  });

  return new Response(stream, {
    headers: {
      'Content-Type': 'text/event-stream; charset=utf-8',
      'Cache-Control': 'no-cache, no-transform',
      Connection: 'keep-alive',
    },
  });
}

const textHistoryRecord = {
  id: 456,
  name: 'Greeting',
  createId: 1,
  updateId: 1,
  createName: 'Janlor',
  updateName: 'Janlor',
  createTime: '2026-02-01 09:00:00',
  updateTime: '2026-02-01 09:01:00',
  detailList: [
    {
      id: 2001,
      historyId: 456,
      type: '1',
      contentType: '1',
      content: '你好',
      isLike: null,
      createTime: '2026-02-01 09:00:00',
      updateTime: '2026-02-01 09:00:00',
    },
    {
      id: 2002,
      historyId: 456,
      type: '2',
      contentType: '1',
      content:
        '{"historyId":456,"hasTool":false,"name":null,"msg":"你好，我可以帮你分析经营数据。","arguments":null}',
      isLike: null,
      createTime: '2026-02-01 09:01:00',
      updateTime: '2026-02-01 09:01:00',
    },
  ],
};

const chartHistoryRecord = {
  id: 123,
  name: 'January sales',
  createId: 1,
  updateId: 1,
  createName: 'Janlor',
  updateName: 'Janlor',
  createTime: '2026-01-31 10:00:00',
  updateTime: '2026-01-31 10:01:00',
  detailList: [
    {
      id: 1001,
      historyId: 123,
      type: '1',
      contentType: '1',
      content: '查看一月销售额',
      isLike: null,
      createTime: '2026-01-31 10:00:00',
      updateTime: '2026-01-31 10:00:00',
    },
    {
      id: 1002,
      historyId: 123,
      type: '2',
      contentType: '2',
      content:
        '{"funcType":"querySalesGroupByMonth","chartCommonVoList":[{"bizId":"2026-01","name":"2026-01","value":128800.5}],"accountAgeGroupVoList":null}',
      isLike: '1',
      createTime: '2026-01-31 10:01:00',
      updateTime: '2026-01-31 10:01:00',
    },
  ],
};
