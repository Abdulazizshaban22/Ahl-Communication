# Ahla Suite — v3.5 APPLY (Production Push)
يشمل هذا المسار تنفيذ فوري لما اخترته:
1) **WAF Bot Control + Account Takeover Prevention** على CloudFront/ALB.
2) **CloudWatch Synthetics Canaries** لمسارات /chat /meet /drive.
3) **X-Ray تتبّع موزّع** + إعداد IAM.
4) **Mobile SSO/Push stubs** (iOS/Android/Huawei) + قوالب مفاتيح.
5) **Runbook** خطوة بخطوة + فحوصات ما بعد التطبيق.

> الدمج: انسخ محتويات `terraform/` داخل شجرتك ثم نفّذ `terraform init && terraform apply` بعد تعبئة المتغيرات في `terraform/v3_5.auto.tfvars`.
