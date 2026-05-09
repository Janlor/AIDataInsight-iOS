package com.aidatainsight.android.feature.aichat.application

import com.aidatainsight.android.core.model.contract.ConversationContentKind
import com.aidatainsight.android.core.model.contract.FeedbackState
import com.aidatainsight.android.core.model.contract.FunctionName
import com.aidatainsight.android.core.model.contract.HistoryContentType
import com.aidatainsight.android.core.model.contract.HistoryDetail
import com.aidatainsight.android.core.model.contract.HistoryDetailType
import kotlin.test.Test
import kotlin.test.assertEquals

class AIChatApplicationMapperTest {
    @Test
    fun makeMessages_mapsHistoryChartContentToChartMessage() {
        val messages = AIChatApplicationMapper.makeMessages(
            listOf(
                HistoryDetail(
                    id = 1001,
                    type = HistoryDetailType.Question,
                    contentType = HistoryContentType.Ai,
                    content = "查看一月销售额",
                ),
                HistoryDetail(
                    id = 1002,
                    type = HistoryDetailType.Answer,
                    contentType = HistoryContentType.Chart,
                    content = """{"funcType":"querySalesGroupByMonth","chartCommonVoList":[{"bizId":"2026-01","name":"2026-01","value":128800.5}],"accountAgeGroupVoList":null}""",
                    isLike = "1",
                ),
            ),
        )

        assertEquals(ConversationContentKind.Text, messages[0].contentKind)
        assertEquals("查看一月销售额", messages[0].text)
        assertEquals(ConversationContentKind.Chart, messages[1].contentKind)
        assertEquals(FeedbackState.Liked, messages[1].feedback)
        assertEquals(1002, messages[1].historyDetailId)
        assertEquals(FunctionName.QuerySalesGroupByMonth, messages[1].functionName)
        assertEquals(1, messages[1].chartPayload?.series?.size)
    }

    @Test
    fun makeMessages_mapsEmptyChartContentToFallbackMessage() {
        val messages = AIChatApplicationMapper.makeMessages(
            listOf(
                HistoryDetail(
                    id = 1002,
                    type = HistoryDetailType.Answer,
                    contentType = HistoryContentType.Chart,
                    content = """{"funcType":"querySalesGroupByMonth","chartCommonVoList":[],"accountAgeGroupVoList":null}""",
                ),
            ),
        )

        assertEquals(ConversationContentKind.Text, messages.single().contentKind)
        assertEquals("数据分析还在测试阶段，很快就能上线，敬请期待！", messages.single().text)
    }
}

