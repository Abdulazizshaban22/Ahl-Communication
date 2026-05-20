# HOWTO — AWS WAF (CloudFront + ALB)

- **CloudFront**: استخدم `web_acl_id` في مورد `aws_cloudfront_distribution` وأعطه `cloudfront_web_acl_arn` الناتج من Terraform.
- **ALB**: مرّر `alb_arn` لعمل association تلقائي (`aws_wafv2_web_acl_association`).

مراجع:
- AWS ACFP (Account Creation Fraud Prevention) — Managed Rule Group.
- AWS Bot Control — Managed Rule Group.
- ربط WAF بـ CloudFront — عبر web_acl_id أو من الكونسول.