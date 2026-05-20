/**
 * Collects WebRTC metrics via getStats and posts to AIF topic endpoint.
 */
export function startWebRtcMetrics(pc: RTCPeerConnection, userId: string) {
  const intervalMs = 5000;
  const timer = setInterval(async () => {
    try {
      const stats = await pc.getStats();
      let out: any[] = [];
      stats.forEach((r) => {
        if (r.type === 'inbound-rtp' && r.kind === 'audio' || r.kind === 'video') {
          out.push({
            ts: Date.now(),
            userId,
            type: r.type,
            kind: r.kind,
            ssrc: r.ssrc,
            packetsLost: r.packetsLost,
            jitter: r.jitter,
            framesDecoded: r.framesDecoded,
            bytesReceived: r.bytesReceived,
            jitterBufferDelay: r.jitterBufferDelay,
            jitterBufferTargetDelay: r.jitterBufferTargetDelay
          });
        }
      });
      if (out.length) {
        fetch('/aif/ingest/webrtc', {
          method: 'POST',
          headers: {'content-type':'application/json'},
          body: JSON.stringify(out),
          keepalive: true
        });
      }
    } catch (e) {
      console.error('webrtc metrics error', e);
    }
  }, intervalMs);
  return () => clearInterval(timer);
}
