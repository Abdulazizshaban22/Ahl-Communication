# Ahla Chat — Expo LIVE (NATS WS + optional E2EE)
Build: 2025-10-20T07:29:17.559124Z

## تشغيل فوري (وضع محلي)
```bash
npm install
npm start
```
اختر iOS/Android/QR — يعمل فورًا (Echo محلي).

## وضع LIVE (NATS WebSocket)
1) عدّل `config.json`:
```json
{
  "mode": "nats",
  "roomId": "general",
  "userId": "user-1",
  "e2ee": true,
  "psk": "000102030405060708090a0b0c0d0e0f000102030405060708090a0b0c0d0e0f",
  "nats": {
    "servers": ["ws://YOUR_HOST:9222"],
    "token": ""
  }
}
```
2) شغّل NATS محليًا (Docker):
```bash
docker run -p 4222:4222 -p 9222:9222 nats:2.10 -js -ws 0.0.0.0:9222
```
3) افتح التطبيق على جهازين — اكتب رسالة في أحدهما لتظهر فورًا على الآخر.

> التشفير (اختياري): عند تشغيل `e2ee=true` تُشفر الرسائل بـ **TweetNaCl secretbox** بمفتاح PSK (تجريبي).

## المجلدات
- `src/natsClient.js`: اتصال NATS + publish/subscribe.
- `src/crypto.js`: تشفير اختياري بسيط (للتجارب).
- `config.json`: إعدادات الوضع (محلي/حي) + السيرفر.

> لاحقًا: استبدال PSK ببروتوكول تأسيس مفاتيح (X3DH/Signal) داخل `ahla-core` Rust.
