# Ahla Chat Mobile v1 (Integrated)
Build: 2025-10-20T07:41:24.442976Z

iOS (SwiftUI) + Android (Compose) متصلان بالنواة Rust (Phase C) عبر FFI/JNI.
اتّبع الخطوات داخل هذا الملف وابدأ تشغيل النسخ مباشرة بعد بناء مكتبة Rust.

## خطوات عامة
- استخدم Phase C لبناء مكتبة `ahla-core` (iOS `.a` + Android `.so`) وترويسة `ahla_core.h`.
- انسخ المخرجات إلى مجلدات iOS و Android كما هو موضح أدناه.

## iOS
1) أضِف `include/ahla_core.h` وارتبط بالمكتبة (XCFramework أو `.a`).
2) افتح `ios/AhlaChat/Sources/` في مشروع Xcode — شغّل المحاكي.

## Android
1) ضع `libahla_core.so` في `android/app/src/main/jniLibs/<abi>/`.
2) افتح `android/` في Android Studio — شغّل التطبيق.

## NATS للتجربة
```bash
docker run -p 4222:4222 nats:2.10 -js
```
ثم عدّل العناوين في `App.swift` و `MainActivity.kt` على LAN.
