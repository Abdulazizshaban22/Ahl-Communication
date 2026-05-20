// Browser-side example for WebRTC E2EE using Insertable Streams (Encoded Transforms)
async function setupE2EE(peerConnection, keyBytes) {
  const key = await crypto.subtle.importKey('raw', keyBytes, 'AES-GCM', false, ['encrypt','decrypt']);

  function createTransform(direction) {
    return new TransformStream({
      async transform(chunk, controller) {
        try {
          if (direction === 'encode') {
            const iv = crypto.getRandomValues(new Uint8Array(12));
            const data = new Uint8Array(chunk.data);
            const ct = new Uint8Array(await crypto.subtle.encrypt({name:'AES-GCM', iv}, key, data));
            chunk.data = ct;
            chunk.getMetadata().encryption = { iv };
          } else {
            const iv = chunk.getMetadata().encryption?.iv;
            if (!iv) return controller.enqueue(chunk);
            const pt = new Uint8Array(await crypto.subtle.decrypt({name:'AES-GCM', iv}, key, chunk.data));
            chunk.data = pt;
          }
          controller.enqueue(chunk);
        } catch (e) {
          console.warn('E2EE transform error', e);
          controller.enqueue(chunk);
        }
      }
    });
  }

  for (const sender of peerConnection.getSenders()) {
    const senderTransform = createTransform('encode');
    sender.createEncodedStreams().readable
      .pipeThrough(senderTransform)
      .pipeTo(sender.createEncodedStreams().writable);
  }

  for (const receiver of peerConnection.getReceivers()) {
    const receiverTransform = createTransform('decode');
    receiver.createEncodedStreams().readable
      .pipeThrough(receiverTransform)
      .pipeTo(receiver.createEncodedStreams().writable);
  }
}
