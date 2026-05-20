# Ahla Mobile — Phase B (iOS + Android Apps)
Build: 2025-10-20T07:04:40.391715Z

هذه الحزمة تُشغّل تطبيقات جوال أصلية (SwiftUI + Jetpack Compose) متصلة بـ **ahla-core (Rust FFI)** من Phase A.

## المتطلبات
- Phase A: `AhlaCore.xcframework` + `include/ahla_core.h` + `android/jniLibs/*/libahla_core.so` جاهزة من الحزمة السابقة.
- iOS: Xcode 15+، Swift 5.9+
- Android: Android Studio Giraffe+، Kotlin 1.9+، NDK

---

## iOS — SwiftUI
1) أنشئ مشروع iOS جديد "AhlaChatDemo" (App).
2) أضِف **AhlaCore.xcframework** إلى المشروع (Embed & Sign).
3) أضِف ملف `AhlaChatDemo-Bridging-Header.h` من هذه الحزمة إلى المشروع واضبطه في Build Settings > Objective-C Bridging Header.
4) أضِف `include/ahla_core.h` إلى المشروع (Header Search Path إن لزم).
5) أدرج الملفات من `ios/Sources/` (App.swift, Views, ViewModels, Bridge).

شغِّل المشروع على جهاز/المحاكي — سترى قائمة محادثات بسيطة + شاشة محادثة تستدعي دوال FFI (`ahla_echo`, `ahla_encrypt_xor`).

---

## Android — Jetpack Compose
1) انسخ مجلد `android/` كامل داخل Android Studio.
2) ضع ملفات Phase A في `android/app/src/main/jniLibs/<abis>/libahla_core.so` (المجلدات موجودة).
3) شغِّل التطبيق — شاشة محادثة Compose تتصل بـ JNI (`AhlaCore.echo`, `AhlaCore.encryptXor`).

---

## أين أربط البث الفوري؟
- لاحقًا: استبدل الـ echo/xor بواجهات حقيقية في ahla-core (NATS WS، تشفير، تخزين محلي).
- استخدم ViewModels لربط الـ flows/Combine مع واجهة SwiftUI/Compose.
