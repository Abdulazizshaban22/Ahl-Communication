# Ahla v4 Patch — ExternalDNS (IRSA) + Amazon RDS (Multi‑AZ) + Secret DB URL
Build: 2025-10-20T05:22:59.934902Z

**هدف الباتش:** دمج تحسينات v5 في ريبوزيتوري **Ahla IaC v4 (Helm + EKS)**:
- تفعيل **ExternalDNS** على EKS عبر **IRSA** (دور IAM مربوط بخدمة Kubernetes) بدلاً من مفاتيح ثابتة.
- ترحيل PostgreSQL من تشارت Bitnami داخل الكلاستر إلى **Amazon RDS (Multi‑AZ)** + خيار **RDS Proxy**.
- إنشاء **Secret** `ahla-system/db-url` تلقائيًا للتطبيقات.

## كيفية تطبيق الباتش
1) انسخ محتويات هذا المجلد فوق ريبوزيتوري v4 (`ahla_iac_v4_helm_eks/`) بحيث تُستبدل/تُضاف الملفات التالية داخل **terraform/**:
   - `terraform/irsa_externaldns.tf` — تعريف IRSA + إصدار Helm external-dns مربوط بالخدمة.
   - `terraform/rds_postgres.tf` — موارد RDS (Multi‑AZ) + (اختياري) RDS Proxy + Secret `db-url`.
   - `terraform/variables_rds.tf` — متغيرات RDS.
   - `terraform/terraform.tfvars.example.patch` — مثال قِيَم محدث.
2) احذف أو علّق **تثبيت PostgreSQL تشارت Bitnami** من `main.tf` في v4 إن وُجد (هذا الباتش يستبدله بـ RDS).
3) عدّل `terraform.tfvars` لديك: `domain`, `hosted_zone_id`, ومعلمات قاعدة البيانات.
4) نفّذ:
   ```bash
   cd terraform
   terraform init -upgrade
   terraform apply
   ```
5) حدّث تطبيقاتك لتقرأ **DATABASE_URL** من الـSecret:
   ```yaml
   env:
     - name: DATABASE_URL
       valueFrom:
         secretKeyRef:
           name: db-url
           key: url
   ```
