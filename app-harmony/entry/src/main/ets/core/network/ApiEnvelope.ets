export interface ApiEnvelope<T> {
  code: number
  msg?: string | null
  data?: T | null
  trace?: string | null
  tid?: string | null
}

export function requireEnvelopeData<T>(envelope: ApiEnvelope<T>): T {
  if (envelope.data === null || envelope.data === undefined) {
    throw new Error('ApiEnvelope data is empty')
  }
  return envelope.data
}
