// Very simplified transform worker (demo only).
// Replace with SFrame implementation; here we just passthrough frames.
onrtctransform = (event) => {
  const transformer = event.transformer;
  const readable = transformer.readable;
  const writable = transformer.writable;
  const transformStream = new TransformStream({
    async transform(frame, controller) {
      // TODO: encrypt/decrypt the frame.data (insertable audio/video frame)
      controller.enqueue(frame);
    }
  });
  readable.pipeThrough(transformStream).pipeTo(writable);
};
