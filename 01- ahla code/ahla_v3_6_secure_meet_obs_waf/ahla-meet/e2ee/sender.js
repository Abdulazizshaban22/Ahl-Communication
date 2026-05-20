// Attach SFrame encryption to the sender track.
// Requires SFrame implementation in sframe.js (currently passthrough).
import { SFrame } from './sframe.js';

export async function attachSenderE2EE(pc, keyBytes) {
  const sframe = await SFrame.create({ keyBytes, ratchet: true });
  for (const sender of pc.getSenders()) {
    if (!sender.track) continue;

    if (sender.createEncodedVideoStreams) {
      const { readable, writable } = sender.createEncodedVideoStreams();
      const transform = new TransformStream({
        async transform(chunk, controller) {
          const out = await sframe.encrypt(new Uint8Array(chunk.data), { ssrc: chunk.getMetadata?.().synchronizationSource });
          chunk.data = out.buffer;
          controller.enqueue(chunk);
        }
      });
      readable.pipeThrough(transform).pipeTo(writable);
    } else if ('transform' in sender) {
      sender.transform = new RTCRtpScriptTransform({
        transformer: {
          async transform(encoded, controller) {
            const out = await sframe.encrypt(new Uint8Array(encoded.data), { ssrc: encoded.getMetadata?.().synchronizationSource });
            encoded.data = out.buffer;
            controller.enqueue(encoded);
          }
        }
      });
    }
  }
}
