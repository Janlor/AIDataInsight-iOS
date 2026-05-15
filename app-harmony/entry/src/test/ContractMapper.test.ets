import { describe, it, expect } from '@ohos/hypium'
import {
  AIHomeCommand,
  ChartUnit,
  ConversationContentKind,
  ConversationRole,
  FeedbackState,
  FunctionName,
  HistoryContentType,
  HistoryDetail,
  HistoryDetailType
} from '../main/ets/contracts/generated/ContractModels'
import {
  mapLoginResponse,
  mapHistoryDetailsToMessages,
  mapRawChartPayload,
  normalizeTemplateQuestionSet
} from '../main/ets/contracts/mappers/ContractFixtureMappers'

export default function contractMapperTest() {
  describe('contractMapperTest', () => {
    it('normalizes snake case login tokens', 0, () => {
      let output = mapLoginResponse({
        code: 200,
        msg: 'ok',
        data: {
          access_token: 'access-token',
          refresh_token: 'refresh-token'
        }
      })

      expect(output.session.accessToken).assertEqual('access-token')
      expect(output.session.refreshToken).assertEqual('refresh-token')
      expect(output.session.isLogin).assertTrue()
      expect(output.routeIntent).assertEqual(AIHomeCommand.OpenAIHome)
    })

    it('normalizes template questions from embedded json string', 0, () => {
      let template = normalizeTemplateQuestionSet(`{
        "questions": [
          "今年第三季度销售额大于2亿的公司有哪些？",
          "查看仓库中煤炭库存大于5万吨的公司。",
          "列出公司FHJK应收余额超过5000万的客户。"
        ]
      }`)

      expect(template.questions.length).assertEqual(3)
      expect(template.questions[0]).assertEqual('今年第三季度销售额大于2亿的公司有哪些？')
      expect(template.questions[2]).assertEqual('列出公司FHJK应收余额超过5000万的客户。')
    })

    it('maps history text detail to conversation messages', 0, () => {
      let details: Array<HistoryDetail> = [
        {
          id: 2001,
          historyId: 456,
          type: HistoryDetailType.Question,
          contentType: HistoryContentType.Ai,
          content: '你好',
          isLike: null
        },
        {
          id: 2002,
          historyId: 456,
          type: HistoryDetailType.Answer,
          contentType: HistoryContentType.Ai,
          content: '{"historyId":456,"hasTool":false,"name":null,"msg":"你好，我可以帮你分析经营数据。","arguments":null}',
          isLike: null
        }
      ]

      let messages = mapHistoryDetailsToMessages(details)

      expect(messages.length).assertEqual(2)
      expect(messages[0].role).assertEqual(ConversationRole.User)
      expect(messages[0].contentKind).assertEqual(ConversationContentKind.Text)
      expect(messages[0].text).assertEqual('你好')
      expect(messages[1].role).assertEqual(ConversationRole.Assistant)
      expect(messages[1].contentKind).assertEqual(ConversationContentKind.Text)
      expect(messages[1].text).assertEqual('你好，我可以帮你分析经营数据。')
    })

    it('maps history chart detail to conversation chart message', 0, () => {
      let details: Array<HistoryDetail> = [
        {
          id: 1001,
          historyId: 123,
          type: HistoryDetailType.Question,
          contentType: HistoryContentType.Ai,
          content: '查看一月销售额',
          isLike: null
        },
        {
          id: 1002,
          historyId: 123,
          type: HistoryDetailType.Answer,
          contentType: HistoryContentType.Chart,
          content: '{"funcType":"querySalesGroupByMonth","chartCommonVoList":[{"bizId":"2026-01","name":"2026-01","value":128800.5}],"accountAgeGroupVoList":null}',
          isLike: '1'
        }
      ]

      let messages = mapHistoryDetailsToMessages(details)
      let chartPayload = messages[1].chartPayload

      expect(messages[1].contentKind).assertEqual(ConversationContentKind.Chart)
      expect(messages[1].feedback).assertEqual(FeedbackState.Liked)
      expect(messages[1].historyDetailId).assertEqual(1002)
      expect(messages[1].functionName).assertEqual(FunctionName.QuerySalesGroupByMonth)
      expect(chartPayload?.unit).assertEqual(ChartUnit.Currency)
      expect(chartPayload?.series.length).assertEqual(1)
      expect(chartPayload?.series[0].xAxis).assertEqual('2026-01')
      expect(chartPayload?.series[0].values[0]).assertEqual(128800.5)
    })

    it('maps chart fixture payload to chart series', 0, () => {
      let payload = mapRawChartPayload({
        funcType: 'querySalesGroupByMonth',
        chartCommonVoList: [
          {
            bizId: '2026-01',
            name: '2026-01',
            value: 128800.5
          }
        ]
      })

      expect(payload.functionName).assertEqual(FunctionName.QuerySalesGroupByMonth)
      expect(payload.unit).assertEqual(ChartUnit.Currency)
      expect(payload.series.length).assertEqual(1)
      expect(payload.series[0].labels[0]).assertEqual('2026-01')
      expect(payload.series[0].values[0]).assertEqual(128800.5)
      expect(payload.emptyMessage).assertEqual(null)
    })
  })
}
