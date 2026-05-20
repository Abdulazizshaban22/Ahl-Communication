// SFrame-like wrapper (PLACEHOLDER — passthrough).
// Replace with a real SFrame implementation.
export class SFrame {
  static async create({ keyBytes, ratchet = true } = {}) {
    return new SFrame(keyBytes, ratchet);
  }
  constructor(keyBytes, ratchet) {
    this.keyBytes = keyBytes;
    this.ratchet = ratchet;
  }
  async encrypt(buf /* Uint8Array */, { ssrc } = {}) {
    return new Uint8Array(buf); // TODO: replace with SFrame encryption
  }
  async decrypt(buf /* Uint8Array */, { ssrc } = {}) {
    return new Uint8Array(buf); // TODO: replace with SFrame decryption
  }
}
