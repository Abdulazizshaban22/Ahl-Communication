// Captures mic PCM and posts chunks to Orchestrator (AIF) for ASR+Emotion.
// Assumes a local /v1/asr and /v1/emotion endpoints.
export async function startLiveBridge(stream, { asrUrl, emoUrl, sessionId }) {
  const audioCtx = new AudioContext();
  const src = audioCtx.createMediaStreamSource(stream);
  const processor = audioCtx.createScriptProcessor(4096, 1, 1);
  src.connect(processor); processor.connect(audioCtx.destination);

  processor.onaudioprocess = async (e) => {
    const pcm = e.inputBuffer.getChannelData(0);
    const buf = new Int16Array(pcm.length);
    for (let i = 0; i < pcm.length; i++) buf[i] = Math.max(-1, Math.min(1, pcm[i])) * 0x7FFF;

    await fetch(asrUrl, { method: 'POST', headers: {'Content-Type':'application/octet-stream', 'X-Session':sessionId}, body: buf });
    // Optionally batch emotion: await fetch(emoUrl, {...})
  };
}
