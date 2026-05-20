# Ahla Core — Phase A (Rust FFI for iOS & Android)
Build: 2025-10-20T07:01:31.244932Z

This pack gives you a working Rust core library with **C ABI** + **JNI** bindings, plus **Swift/Kotlin samples**.

## iOS (XCFramework)
- Targets: `aarch64-apple-ios`, `aarch64-apple-ios-sim`
- Build static `.a` and create XCFramework, header via `cbindgen`

## Android (.so + JNI)
- Use `cargo-ndk` to build `libahla_core.so` for `arm64-v8a`, `armeabi-v7a`, `x86_64`
- Kotlin uses `System.loadLibrary("ahla_core")` and external JNI functions

See scripts in `scripts/` and samples in `samples/`.
