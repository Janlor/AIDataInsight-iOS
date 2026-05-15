import { ApiError, ApiErrorKind } from './ApiError'
import { HttpTransport, ResolvedApiRequest } from './CommonRequester'

export class MockHttpTransport implements HttpTransport {
  private responses: Map<string, string>

  constructor(responses: Map<string, string> = new Map<string, string>()) {
    this.responses = responses
  }

  register(path: string, responseText: string): void {
    this.responses.set(path, responseText)
  }

  async send(request: ResolvedApiRequest): Promise<string> {
    let response = this.responses.get(request.path)
    if (response === undefined) {
      throw new ApiError(ApiErrorKind.Transport, `Mock response not found: ${request.path}`)
    }
    return response
  }
}
