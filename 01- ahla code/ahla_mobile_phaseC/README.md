# Ahla Mobile — Phase C (Rust E2EE + SQLite + NATS FFI)
Build: 2025-10-20T07:33:43.497682Z

هذه الحزمة تقدّم **نواة Rust** متقدمة تربط iOS/Android عبر FFI/JNI، مع:
- **E2EE** مبسّط: X25519 (مفتاح مشترك) + ChaCha20-Poly1305 (تشفير متماثل).
- **تخزين محلي** rusqlite (bundled sqlite3) مع تشفير على مستوى المحتوى (envelope).
- **NATS TCP** (async-nats) للنشر/الاشتراك، + **poll** FFI لاستلام الرسائل.
- أمثلة Swift/Kotlin لاستدعاء الدوال.

> ملاحظة حول SQLCipher: نوفر تعمية على مستوى المحتوى (قبل التخزين). يمكن استبدال sqlite3 بـ **SQLCipher** لاحقًا باتباع دليل Zetetic (انظر docs/SQLCIPHER.md).

## بناء iOS (XCFramework)
```bash
rustup target add aarch64-apple-ios aarch64-apple-ios-sim
cargo install cbindgen
cd core/ahla-core
cargo build --release --target aarch64-apple-ios
cargo build --release --target aarch64-apple-ios-sim
cbindgen --config cbindgen.toml --crate ahla-core --output ../../include/ahla_core.h
# أنشئ XCFramework حسب دليل Phase A أو استورد .a مباشرة
```

## بناء Android (.so)
```bash
cargo install cargo-ndk
rustup target add aarch64-linux-android armv7-linux-androideabi x86_64-linux-android
cd core/ahla-core
cargo ndk -t arm64-v8a -o ../../android/jniLibs build --release
cargo ndk -t armeabi-v7a -o ../../android/jniLibs build --release
cargo ndk -t x86_64 -o ../../android/jniLibs build --release
```

## ربط NATS
- عدّل العنوان/التوكن في استدعاء `ahla_nats_connect("tls://demo.nats.io:4443","")` أو `nats://host:4222`.
- اشترك: `ahla_nats_subscribe_room("general")`
- انشر: `ahla_nats_publish_room("general", "hello")`
- اسحب الرسائل الواردة: `ahla_nats_poll_json()` (تعيد JSON أو NULL).

## دوال FFI المتاحة
- تهيئة/مفاتيح:
  - `ahla_init()` — تشغيل runtime والخزن.
  - `ahla_kp_generate()` — يولد زوج مفاتيح ويحفظها.
  - `ahla_pubkey_hex()` — يرجع المفاتيح العامة hex.
  - `ahla_set_peer_pubkey_hex(hex)` — ضبط مفتاح نظير.
- تشفير:
  - `ahla_encrypt_text(plain)` / `ahla_decrypt_text(b64)`
- تخزين:
  - `ahla_db_open(path)` — فتح/إنشاء قاعدة.
  - `ahla_store_message(room, mine, plain)` — يخزن بنص مشفّر.
  - `ahla_export_room_json(room)` — يرجع JSON بالرسائل (بعد فك التشفير).
- NATS:
  - `ahla_nats_connect(url, token)`
  - `ahla_nats_subscribe_room(room)`
  - `ahla_nats_publish_room(room, plain)` — يُشفّر تلقائياً قبل النشر.
  - `ahla_nats_poll_json()` — يسحب رسالة واردة (JSON).

انظر أمثلة `samples/ios` و`samples/android`.
