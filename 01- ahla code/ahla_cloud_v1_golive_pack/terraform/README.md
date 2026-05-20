# Terraform — Aurora + S3 Backups + IRSA

- `aurora/` : مثال إنشاء **Aurora PostgreSQL** مع نسخ تلقائي (Backup window/retention).
- `irsa-externaldns/` : سياسة IAM وربط IRSA لـ ExternalDNS على Route53.
- `s3-backup/` : Bucket مع تشفير/نسخ/قواعد عمر الملفات.
