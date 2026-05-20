# Ahla Chat — E2EE (Signal/MLS) Scaffolding

- This directory contains integration points to wire **libsignal-protocol** (Rust/WASM or language bindings) or **MLS (RFC 9420)** for group messaging.
- For mobile (iOS/Android), use native libsignal. For web, either use MLS via a WASM lib or fall back to a bridge service that performs Double Ratchet with keys stored client-side (never on server).

## Folders
- `/signal/` — placeholders for session setup, pre-keys, sealed sender.
- `/mls/` — placeholders for group key schedule and epoch updates.
- `/keystore/` — browser IndexedDB wrappers for key material (WebCrypto).
