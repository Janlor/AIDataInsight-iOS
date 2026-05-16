import { describe, it, expect } from '@ohos/hypium'
import { ConversationRole, FeedbackState } from '../../main/ets/core/model/ContractModelExports'
import { MockAIChatRepository } from '../../main/ets/feature/ai_chat/application/AIChatRepository'
import { AIChatRuntimeStore } from '../../main/ets/feature/ai_chat/application/AIChatRuntime'
import {
  AIChatMessageContentKind,
  aiChatChartFallbackText,
  buildAIChatUiState,
  initialAIChatUiState,
  makeUserMessage
} from '../../main/ets/feature/ai_chat/application/AIChatState'

export default function aiChatStateTest() {
  describe('aiChatStateTest', () => {
    it('loads template questions without appending messages', 0, async () => {
      let runtime = new AIChatRuntimeStore(new MockAIChatRepository())
      let state = await runtime.loadTemplate()

      expect(state.templateQuestions.length).assertEqual(5)
      expect(state.templateQuestions[0]).assertEqual('今年第三季度销售额大于2亿的公司有哪些？')
      expect(state.templateQuestions[4]).assertEqual('查看各公司账龄超过180天的金额。')
      expect(state.messages.length).assertEqual(0)
      expect(state.isLoadingTemplate).assertFalse()
      expect(state.canClear).assertFalse()
    })

    it('sends a chart question and supports feedback state', 0, async () => {
      let runtime = new AIChatRuntimeStore(new MockAIChatRepository())
      await runtime.loadTemplate()
      let state = await runtime.sendMessage('查询本月销售额')

      expect(state.historyId).assertEqual(1001)
      expect(state.messages.length).assertEqual(2)
      expect(state.messages[0].role).assertEqual(ConversationRole.User)
      expect(state.messages[1].contentKind).assertEqual(AIChatMessageContentKind.Chart)
      expect(state.messages[1].chartPayload?.series.length).assertEqual(2)

      let feedbackState = await runtime.sendFeedback(state.messages[1].historyDetailId ?? 0, '0')
      expect(feedbackState.messages[1].feedback).assertEqual(FeedbackState.Disliked)
    })

    it('streams non-chart mock responses', 0, async () => {
      let runtime = new AIChatRuntimeStore(new MockAIChatRepository())
      await runtime.loadTemplate()
      let state = await runtime.sendMessage('帮我分析经营情况')

      expect(state.messages.length).assertEqual(2)
      expect(state.messages[1].contentKind).assertEqual(AIChatMessageContentKind.Text)
      expect((state.messages[1].text?.indexOf('mock 数据') ?? -1) > 0).assertTrue()
      expect(state.isStreaming).assertFalse()
    })

    it('keeps contract fallback copy available for chart failure', 0, () => {
      let state = buildAIChatUiState(
        1001,
        [
          makeUserMessage('local-user-1', '查询本月销售额')
        ],
        new Array<string>(),
        '',
        false,
        false,
        false,
        null,
        true
      )

      expect(initialAIChatUiState().canSend).assertFalse()
      expect(state.canClear).assertTrue()
      expect(aiChatChartFallbackText).assertEqual('数据分析还在测试阶段，很快就能上线，敬请期待！')
    })
  })
}
