package com.aidatainsight.android.core.network.client

import com.aidatainsight.android.core.network.auth.NetworkCredentialProvider
import com.aidatainsight.android.core.network.auth.SessionInvalidationHandler
import com.aidatainsight.android.core.network.auth.TokenRefreshCoordinator
import com.aidatainsight.android.core.network.auth.TokenRefreshService
import com.aidatainsight.android.core.network.model.OAuthModel
import com.aidatainsight.android.core.network.service.KtorAuthRemoteService
import io.ktor.client.HttpClient
import io.ktor.client.engine.mock.MockEngine
import io.ktor.client.engine.mock.respond
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.client.request.HttpRequestData
import io.ktor.http.HttpHeaders
import io.ktor.http.HttpStatusCode
import io.ktor.http.headersOf
import io.ktor.serialization.kotlinx.json.json
import kotlinx.coroutines.runBlocking
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNotNull
import kotlin.test.assertTrue

class AIDataInsightApiClientTest {
    @Test
    fun post_sendsJsonBody() = runBlocking {
        var request: HttpRequestData? = null
        val engine = MockEngine {
            request = it
            respond(
                content = """{"code":200,"data":{"accessToken":"access-1","refreshToken":"refresh-1"}}""",
                status = HttpStatusCode.OK,
                headers = headersOf(HttpHeaders.ContentType, "application/json"),
            )
        }
        val service = KtorAuthRemoteService(apiClient(engine))

        val model = service.login(username = "demo", password = "pwd")

        val body = request?.body?.toString().orEmpty()
        assertEquals("access-1", model?.accessToken)
        assertTrue(body.contains("demo"))
        assertTrue(body.contains("pwd"))
        assertEquals("Bearer access-token", request?.headers?.get(HttpHeaders.Authorization))
        assertEquals("7", request?.headers?.get("Org-Id"))
    }

    @Test
    fun response402_refreshesAndRetriesOnce() = runBlocking {
        var requestCount = 0
        val refreshService = FakeTokenRefreshService()
        val invalidationHandler = FakeSessionInvalidationHandler()
        val engine = MockEngine {
            requestCount += 1
            if (requestCount == 1) {
                respond(
                    content = """{"code":402,"msg":"expired"}""",
                    status = HttpStatusCode.OK,
                    headers = headersOf(HttpHeaders.ContentType, "application/json"),
                )
            } else {
                respond(
                    content = """{"code":200,"data":{"accessToken":"access-2"}}""",
                    status = HttpStatusCode.OK,
                    headers = headersOf(HttpHeaders.ContentType, "application/json"),
                )
            }
        }
        val service = KtorAuthRemoteService(
            apiClient(
                engine = engine,
                tokenRefreshService = refreshService,
                sessionInvalidationHandler = invalidationHandler,
            ),
        )

        val model = service.refreshToken("refresh-token")

        assertEquals("access-2", model?.accessToken)
        assertEquals(2, requestCount)
        assertEquals(listOf("refresh-token"), refreshService.receivedTokens)
        assertFalse(invalidationHandler.invalidated)
    }

    private fun apiClient(
        engine: MockEngine,
        tokenRefreshService: FakeTokenRefreshService = FakeTokenRefreshService(),
        sessionInvalidationHandler: FakeSessionInvalidationHandler = FakeSessionInvalidationHandler(),
    ): AIDataInsightApiClient {
        val httpClient = HttpClient(engine) {
            install(ContentNegotiation) {
                json(AIDataInsightHttpClientFactory.json)
            }
        }
        return AIDataInsightApiClient(
            config = NetworkConfig(baseUrl = "https://example.test"),
            httpClient = httpClient,
            credentialProvider = FakeCredentialProvider(),
            tokenRefreshCoordinator = TokenRefreshCoordinator(tokenRefreshService),
            sessionInvalidationHandler = sessionInvalidationHandler,
        )
    }
}

private class FakeCredentialProvider : NetworkCredentialProvider {
    override val accessToken: String? = "access-token"
    override val refreshToken: String? = "refresh-token"
    override val orgId: Int? = 7
}

private class FakeTokenRefreshService : TokenRefreshService {
    val receivedTokens = mutableListOf<String>()

    override suspend fun refreshToken(token: String): Boolean {
        receivedTokens += token
        return true
    }
}

private class FakeSessionInvalidationHandler : SessionInvalidationHandler {
    var invalidated: Boolean = false

    override fun invalidateSession(message: String?) {
        invalidated = true
    }
}

