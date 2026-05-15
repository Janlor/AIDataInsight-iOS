import { apiErrorFromCode, ApiError, ApiErrorKind } from './ApiError'
import { ApiEnvelope, requireEnvelopeData } from './ApiEnvelope'
import { ApiEnvironmentProvider, defaultApiEnvironmentProvider } from './ApiEnvironmentProvider'

export enum HttpMethod {
  Get = 'GET',
  Post = 'POST'
}

export interface ApiRequest {
  path: string
  method: HttpMethod
  headers?: Record<string, string>
  body?: object | string | null
}

export interface HttpTransport {
  send(request: ResolvedApiRequest): Promise<string>
}

export interface ResolvedApiRequest extends ApiRequest {
  url: string
}

export class CommonRequester {
  private environmentProvider: ApiEnvironmentProvider
  private transport: HttpTransport

  constructor(
    transport: HttpTransport,
    environmentProvider: ApiEnvironmentProvider = defaultApiEnvironmentProvider
  ) {
    this.transport = transport
    this.environmentProvider = environmentProvider
  }

  async request<T>(request: ApiRequest): Promise<T> {
    let responseText = await this.transport.send({
      ...request,
      url: this.environmentProvider.resolve(request.path)
    })

    let envelope = this.decodeEnvelope<T>(responseText)
    let error = apiErrorFromCode(envelope.code, envelope.msg)
    if (error !== null) {
      throw error
    }

    return requireEnvelopeData(envelope)
  }

  private decodeEnvelope<T>(responseText: string): ApiEnvelope<T> {
    try {
      return JSON.parse(responseText) as ApiEnvelope<T>
    } catch (error) {
      throw new ApiError(ApiErrorKind.Decode, `接口响应解析失败: ${JSON.stringify(error)}`)
    }
  }
}
