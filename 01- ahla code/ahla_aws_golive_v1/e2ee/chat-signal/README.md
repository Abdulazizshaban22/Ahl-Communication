# Chat E2EE with Signal Protocol (sketch)

This folder shows how to wire libsignal (TypeScript) into Ahla Chat.
Steps:
1) Generate identity + prekeys per device.
2) Publish prekeys to your key server (Ahla ID).
3) Establish a session, then encrypt/decrypt every message payload before sending via WS.

See `store.ts` and `session.ts` for minimal scaffolding.
