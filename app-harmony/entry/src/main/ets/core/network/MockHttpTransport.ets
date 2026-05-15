import { ApiError, ApiErrorKind } from './ApiError'
import { ResolvedApiRequest } from './CommonRequester'

export class MockHttpTransport {
  private responses: Record<string, string>

  constructor(responses: Record<string, string> = {}) {
    this.responses = responses
  }

  register(path: string, responseText: string): void {
    this.responses[path] = responseText
  }

  async send(request: ResolvedApiRequest): Promise<string> {
    let response = this.responses[request.path]
    if (response === undefined) {
      throw new ApiError(ApiErrorKind.Transport, `Mock response not found: ${request.path}`)
    }
    return response
  }
}
