Place your whisper.cpp WASM build and model files here, for example:
- /chat/whisper/whisper.wasm
- /chat/whisper/whisper.js
- /chat/whisper/ggml-tiny.bin

This app will attempt to load whisper.js; if not found, it will fallback to Web Speech API (if available).