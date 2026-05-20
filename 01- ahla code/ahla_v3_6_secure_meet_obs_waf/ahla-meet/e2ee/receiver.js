// Attach SFrame decryption to the receiver track.
// Requires SFrame implementation in sframe.js (currently passthrough).
import { SFrame } from './sframe.js';

export async function attachReceiverE2EE(pc, keyBytes) {
  const sframe = await SFrame.create({ keyBytes, ratchet: true });
  for (const receiver of pc.getReceivers()) {
    if (!receiver.track) continue;

    if (receiver.createEncodedVideoStreams) {
      const { readable, writable } = receiver.createEncodedVideoStreams();
      const transform = new TransformStream({
        async transform(chunk, controller) {
          const out = await sframe.decrypt(new Uint8Array(chunk.data), { ssrc: chunk.getMetadata?.().synchronizationSource });
          chunk.data = out.buffer;
          controller.enqueue(chunk);
        }
      });
      readable.pipeThrough(transform).pipeTo(writable);
    } else if ('transform' in receiver) {
      receiver.transform = new RTCRtpScriptTransform({
        transformer: {
          async transform(encoded, controller) {
            const out = await sframe.decrypt(new Uint8Array(encoded.data), { ssrc: encoded.getMetadata?.().synchronizationSource });
            encoded.data = out.buffer;
            controller.enqueue(encoded);
          }
        }
      });
    }
  }
}
