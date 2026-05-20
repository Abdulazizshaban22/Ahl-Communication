// Placeholder: Signal session bootstrap (client-side).
// Use libsignal-protocol (WASM or native) to generate identity/one-time prekeys.
// Never send private keys to the server; store in IndexedDB/SecureStorage.
export async function initSignalSession(peerId: string) {
  // TODO: integrate libsignal-protocol; this is a stub.
  return { ok: true, peerId };
}
