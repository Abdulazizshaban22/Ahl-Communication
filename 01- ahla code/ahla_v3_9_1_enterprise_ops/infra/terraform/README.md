# Ahla v3.9.1 — Attach WAF + Grafana Apdex + SLO Burn-rate Alerts

## WAF Association
- **CloudFront**: set `web_acl_id = var.cloudfront_web_acl_arn` on your `aws_cloudfront_distribution` (CLOUDFRONT scope).
- **ALB (optional)**: pass `alb_arn` to auto-associate regional WAF via `aws_wafv2_web_acl_association`.

## SLO Burn-rate (Two Windows + Composite)
- Uses ALB metrics (`HTTPCode_Target_5XX_Count` / `RequestCount`) to calculate error rate.
- **Burn rate** = `error_rate / error_budget`, where `error_budget = 100 - slo_target`.
- Creates:
  - Alarm (1h, threshold > 2x),
  - Alarm (6h, threshold > 1x),
  - Composite alarm (`AND`) + SNS for notifications.
- Set `alb_load_balancer`, `alb_target_group`, `sns_email` in `terraform.tfvars`.

## Apply
```bash
cd infra/terraform
terraform init
terraform apply -var="cloudfront_web_acl_arn=arn:aws:wafv2:us-east-1:123:global/webacl/..." \ 
                -var="alb_load_balancer=app/ahla-alb/..."                 -var="alb_target_group=targetgroup/ahla-chat/..."                 -var="sns_email=ops@example.com"
```

## Apdex in Grafana
- Push `Apdex` as custom CloudWatch metric (0..1) per خدمة (Chat/Meet/Drive/Mail).
- استورد لوحتي Grafana الجاهزتين من `grafana/dashboards`.
