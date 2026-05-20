# Ahla — Terraform (Prod)
- يوفّر الشبكة (VPC/NAT)، RDS Postgres، ECS/Fargate لخدمات: chat-api, mail-api, drive-api, business-api, meet-signaling، وEdge: CloudFront+WAF فوق ALB.
- يترك خيار الرسائل لك: MSK (Serverless/IAM) أو NATS مُدار ذاتيًا (خارج هذا السكربت).

## خطوات
1) انسخ هذا المجلد داخل `infra/` في الجذر.
2) املأ `prod.auto.tfvars` من المثال.
3) شغّل `terraform init && terraform apply`.
