# Ahla Meet — E2EE via Insertable Streams + SFrame (skeleton)

This folder provides front-end hooks for end-to-end media encryption:
- `sender.js` and `receiver.js` attach WebRTC Encoded Transform (or RTCRtpScriptTransform) to encrypt/decrypt frames.
- `sframe.js` is a placeholder API compatible with a future SFrame implementation. **It currently passes data through**.
- Keys should be derived/distributed via MLS (see `../mls/`), and **must never be stored on servers**.

> IMPORTANT: Replace `sframe.js` with a production SFrame library before going live.
