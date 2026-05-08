package com.aidatainsight.android.core.network.client

import io.ktor.client.HttpClient
import io.ktor.client.engine.okhttp.OkHttp
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.serialization.kotlinx.json.json
import kotlinx.serialization.json.Json

object AIDataInsightHttpClientFactory {
    val json: Json = Json {
        ignoreUnknownKeys = true
        encodeDefaults = true
    }

    fun create(): HttpClient = HttpClient(OkHttp) {
        install(ContentNegotiation) {
            json(json)
        }
    }
}
