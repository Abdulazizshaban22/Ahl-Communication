# Ahla — One‑Command Go‑Live v1
Build: 2025-10-20T06:02:30.988956Z

هذه الحزمة تشغّل **كامل منظومة أهلا** بأمر واحد:
- ingress‑nginx + cert‑manager (ACME/HTTP‑01) + ExternalDNS
- مراقبة (kube‑prometheus‑stack)
- **ahla‑cloud** (NATS JetStream WS + CoTURN 443/TLS + KEDA + ClusterIssuer)
- **ahla‑suite** (Notes/Book/Graph/Dote/Dash + Content API) مع SSO/NATS/DB

## التحضير
1) حرّر ملف `.env` من `.env.example`.
2) تأكد من صلاحية `kubectl` على الكلاستر (EKS/أو أي K8s).
3) يجب أن تكون لديك صلاحية Route53 على الـHosted Zone (لـExternalDNS).

## التشغيل (أمر واحد)
```bash
bash scripts/go-live.sh
```
سيتولّى السكربت إضافة الـrepos، إنشاء القيم من `.env`، ونشر كل شيء.

## التدمير (اختياري)
```bash
bash scripts/destroy.sh
```
