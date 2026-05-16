import { http } from '@kit.NetworkKit'
import { util } from '@kit.ArkTS'
import { ApiError, ApiErrorKind } from './ApiError'
import { HttpMethod, HttpTransport, ResolvedApiRequest } from './CommonRequester'

export class HarmonyHttpTransport implements HttpTransport {
  async send(request: ResolvedApiRequest): Promise<string> {
    let httpRequest = http.createHttp()
    try {
      let response = await (httpRequest.request(request.url, {
        method: this.requestMethod(request.method),
        header: this.headers(request),
        extraData: this.extraData(request),
        expectDataType: http.HttpDataType.STRING,
        connectTimeout: 15000,
        readTimeout: 60000
      }) as Promise<http.HttpResponse>)
      let statusCode = response.responseCode as number
      if (statusCode < 200 || statusCode >= 300) {
        throw new ApiError(ApiErrorKind.Transport, `HTTP ${statusCode}: ${request.url}`)
      }
      return this.responseText(response.result)
    } catch (error) {
      if (error instanceof ApiError) {
        throw error
      }
      throw new ApiError(ApiErrorKind.Transport, `网络请求失败: ${JSON.stringify(error)}`)
    } finally {
      httpRequest.destroy()
    }
  }

  async sendStream(request: ResolvedApiRequest, onChunk: (chunk: string) => void): Promise<void> {
    let httpRequest = http.createHttp()
    let decoder = util.TextDecoder.create('utf-8')
    let dataEndCallback: () => void = () => {}
    let dataEndPromise = new Promise<void>((resolve: () => void) => {
      dataEndCallback = (): void => {
        resolve()
      }
    })
    let dataCallback = (buffer: ArrayBuffer): void => {
      let text = decoder.decodeToString(new Uint8Array(buffer))
      if (text.length > 0) {
        onChunk(text)
      }
    }
    try {
      httpRequest.on('dataReceive', dataCallback)
      httpRequest.on('dataEnd', dataEndCallback)
      let statusCode = await (httpRequest.requestInStream(request.url, {
        method: this.requestMethod(request.method),
        header: this.headers(request),
        extraData: this.extraData(request),
        connectTimeout: 15000,
        readTimeout: 60000
      }) as Promise<number>)
      if (statusCode < 200 || statusCode >= 300) {
        throw new ApiError(ApiErrorKind.Transport, `HTTP ${statusCode}: ${request.url}`)
      }
      await dataEndPromise
    } catch (error) {
      if (error instanceof ApiError) {
        throw error
      }
      throw new ApiError(ApiErrorKind.Transport, `网络流式请求失败: ${JSON.stringify(error)}`)
    } finally {
      httpRequest.off('dataReceive', dataCallback)
      httpRequest.off('dataEnd', dataEndCallback)
      httpRequest.destroy()
    }
  }

  private requestMethod(method: HttpMethod): http.RequestMethod {
    if (method === HttpMethod.Post) {
      return http.RequestMethod.POST
    }
    return http.RequestMethod.GET
  }

  private headers(request: ResolvedApiRequest): Object {
    let headers: Record<string, string> = {
      'content-type': 'application/json'
    }
    if (request.headers !== undefined) {
      request.headers.forEach((value: string, key: string) => {
        headers[key] = value
      })
    }
    return headers
  }

  private extraData(request: ResolvedApiRequest): string | Object | null {
    if (request.body === undefined || request.body === null) {
      return null
    }
    if (typeof request.body === 'string') {
      return request.body
    }
    return JSON.stringify(request.body)
  }

  private responseText(result: string | Object | ArrayBuffer): string {
    if (typeof result === 'string') {
      return result
    }
    if (result instanceof ArrayBuffer) {
      return this.arrayBufferToString(result)
    }
    return JSON.stringify(result)
  }

  private arrayBufferToString(buffer: ArrayBuffer): string {
    let bytes = new Uint8Array(buffer)
    let text = ''
    for (let index = 0; index < bytes.length; index++) {
      text += String.fromCharCode(bytes[index])
    }
    return text
  }
}
