# WebRTC metrics
- Uses `RTCPeerConnection.getStats()` to sample every 5s.
- Sends jitter, packetsLost, framesDecoded, jitterBufferDelay/TargetDelay.
- Backend should forward to Kafka topic `aif.webrtc.metrics` for real-time analysis.
