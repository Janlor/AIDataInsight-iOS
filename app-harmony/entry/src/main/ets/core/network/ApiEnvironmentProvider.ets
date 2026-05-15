import { ApiEnvironment, aiChatEndpoint, mockApiEnvironment } from '../model/ContractModelExports'

export interface ApiEndpointSet {
  baseUrl: string
  streamPath: string
}

export class ApiEnvironmentProvider {
  private environment: ApiEnvironment

  constructor(environment: ApiEnvironment = mockApiEnvironment) {
    this.environment = environment
  }

  current(): ApiEnvironment {
    return this.environment
  }

  endpoints(): ApiEndpointSet {
    return {
      baseUrl: this.environment.baseUrl,
      streamPath: aiChatEndpoint.streamPath
    }
  }

  resolve(path: string): string {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path
    }

    let baseUrl = this.environment.baseUrl.endsWith('/')
      ? this.environment.baseUrl.substring(0, this.environment.baseUrl.length - 1)
      : this.environment.baseUrl
    let relativePath = path.startsWith('/') ? path : `/${path}`
    return `${baseUrl}${relativePath}`
  }
}

export const defaultApiEnvironmentProvider = new ApiEnvironmentProvider()
