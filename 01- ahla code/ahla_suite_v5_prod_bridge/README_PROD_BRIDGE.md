# Ahla Suite v5 — Prod Bridge
Build: 2025-10-20T05:53:35.097237Z

هذه الحزمة تصل حزمة الإنتاجية / واجهات Ahla بـ **SSO (Keycloak OIDC)** و **NATS WebSocket**،
وتحوّل `content-api` إلى **Postgres/RDS/Aurora**، وتوفّر **Helm Charts** للنشر على **EKS** (جاهزة Go‑Live).

## ما الذي بداخل الحزمة؟
- `packages/realtime/` — عميل NATS WebSocket جاهز للاستخدام من واجهات Next.js.
- `apps/*/app/api/auth/[...nextauth]/route.ts` — تكامل Auth.js (NextAuth) مع **Keycloak** (OIDC).
- `apps/*/middleware.ts` — حماية الصفحات (requires auth).
- `services/content-api` — يدعم `DATABASE_URL` لـ Postgres (psycopg2) + healthz.
- `helm/ahla-suite/` — تشارت مظلة ينشر:
  - واجهات Notes/Book/Graph/Dote/Dash
  - خدمة content-api
  - (اختياري) collab-gateway
- `values.example.yaml` — قيم الضبط (نطاقات، صور، مفاتيح OIDC/NATS).

## المتطلبات
- **Keycloak** مفعّل مع Realm + Client (Confidential) وقيم: `issuer`, `clientId`, `clientSecret`. 
- **ClusterIssuer** من cert-manager ل Let's Encrypt، و **ExternalDNS** شغال على hosted zone.
- **K8s Secret** باسم `ahla-system/db-url` يحوي سلسلة Postgres (تم تسليمها في v4.1/4.2).

## نشر سريع
```bash
# 1) اضبط القيم
cp values.example.yaml values.yaml
# 2) نشر
helm upgrade --install ahla-suite ./helm/ahla-suite -n ahla-system --create-namespace -f values.yaml
```
