# Ahla Suite v5 — CI/CD + NATS Auth
Build: 2025-10-20T05:56:57.381067Z

هذه الحزمة تضيف:
1) **CI/CD (GitHub Actions)** لبناء صور Docker ودفعها إلى Registry ونشر Helm على EKS.
2) **NATS WebSocket Auth** (اسم مستخدم/كلمة مرور + صلاحيات Subjects) + **خدمة Token بسيطة** لإعطاء بيانات اتصال للمتصفح بعد تحقق SSO.
3) تحديث **Helm (ahla-suite)** لتمرير **Image Tags** من CI تلقائيًا.

> ملاحظة أمنية: هذه النسخة تستخدم **Basic Auth (user/pass)** لـ NATS WS كبداية سريعة. للترقية إلى **NATS JWT/NKeys** سوف أرسل Patch لاحق (nsc + Accounts/Users) بدون توقف.

## المتطلبات
- Secrets في GitHub Repo:
  - `REGISTRY` مثال: `ghcr.io/YOUR_ORG`
  - `REGISTRY_USERNAME` + `REGISTRY_PASSWORD` (أو استخدم `GITHUB_TOKEN` مع GHCR).
  - `KUBE_CONFIG` (base64 لمحتوى kubeconfig) أو إعداد OIDC/Role إذا تعمل على EKS.
- في الكلاستر: cert-manager + ExternalDNS + `ahla-system/db-url` (من Patch v4.1).

## التشغيل السريع
- ادفع الكود إلى GitHub. سيتم:
  - **build-and-push** على كل دفع إلى `main`.
  - **deploy** عند وجود Tag `v*` أو تشغيل يدوي، وينفّذ:  
    ```bash
    helm upgrade --install ahla-suite ./helm/ahla-suite -n ahla-system -f values.yaml --set images.*=:{{ github.sha }}
    ```
- لنشر NATS WS Auth:
  ```bash
  helm upgrade --install ahla-nats-ws ./helm/ahla-nats-ws -n ahla-system -f helm/ahla-nats-ws/values.example.yaml
  ```
