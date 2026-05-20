# Mobile APPLY — مفاتيح الدخول والتنبيهات

## iOS
- AppAuth (OIDC): issuer/clientId/redirect = `ahla://auth/callback`
- APNs: حمّل مفتاح .p8 إلى الخادم وخزّنه في Secrets Manager.
- CallKit/PushKit: تأكد من entitlements وتسجيل VoIP token.

## Android
- AppAuth-Android (OIDC): استخدم PKCE.
- FCM HTTP v1: استبدل Legacy بـ v1 وتوكيل حساب خدمة.
- ConnectionService/InCallService: لعرض واجهة المكالمة.

## Huawei
- HMS Push: أضف `agconnect-services.json` وفعّل Push Kit.
