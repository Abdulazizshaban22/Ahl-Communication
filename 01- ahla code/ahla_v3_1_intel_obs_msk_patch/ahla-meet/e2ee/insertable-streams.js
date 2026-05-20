// Insertable Streams E2EE hook (demo).
// NOTE: This is a scaffolding sample (NOT production crypto). Replace with SFrame or audited lib.
export async function attachE2EE(pc, key) {
  // For each sender track, attach a transform that encrypts outgoing frames.
  for (const sender of pc.getSenders()) {
    const transform = new RTCRtpScriptTransform(window, {
      kind: sender.track?.kind,
      // Transform implemented in worker
      workerOptions: {
        name: 'ahla-e2ee-worker'
      }
    });
    sender.transform = transform;
  }
  // Receiver side should mirror decryption with the same key material.
}
