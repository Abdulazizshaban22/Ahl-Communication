# MLS Server (skeleton) for Ahla Meet keying

- Use OpenMLS (Rust) or mlspp (C++) to maintain MLS groups per room.
- On member join/leave, derive a fresh epoch and export a secret for SFrame keying (`exportSecret("sframe")`).
- Only MLS handshake/control messages flow through the server — media remains opaque (E2EE).

## Build (conceptual):
- `cargo run --release` to start a lightweight MLS controller exposing:
  - `POST /rooms` → create
  - `POST /rooms/{id}/join` → add member
  - `POST /rooms/{id}/commit` → rotate keys (epoch)
  - `GET /rooms/{id}/sframe-key` → export current key for the authenticated member
