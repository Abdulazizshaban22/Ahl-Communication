# Ahla v3.9.5 — Unified Terraform + Grafana (WebRTC)

## 1) Terraform
- `modules/waf_acl`: WAFv2 (GLOBAL/us-east-1) مع **BotControl (TARGETED)** + **ACFP** + **ATP** (Response Inspection).
- `modules/chatops`: AWS Chatbot (Slack) لربط SNS بالتنبيهات.
- `modules/msk_serverless`: Kafka Serverless مع IAM SASL.
- `modules/anomaly_alarms`: إنذار **ANOMALY_DETECTION_BAND** على p95 ALB TargetResponseTime.

> CloudFront: استخدم **aws_cloudfront_distribution.web_acl_id** لربط الـACL (ARN شكل `...:global/webacl/...`).

## 2) Grafana
- Datasource CloudWatch + OpenSearch جاهزة (provisioning).
- لوحة جديدة **WebRTC Quality** لقياس (packetsLost/jitter/jitterBufferDelay/TargetDelay).

## 3) تشغيل سريع
```bash
cd infra/terraform
terraform init && terraform apply \  -var="region=eu-central-1" \  -var="name_prefix=ahla" \  -var="alb_name=app/ahla/abc" \  -var="alb_target_group=targetgroup/ahla-chat/xyz" \  -var="sns_topic_arn=arn:aws:sns:eu-central-1:123:ahla-slo-alerts" \  -var="slack_team_id=T000" -var="slack_channel_id=C000" \  -var="chatops_iam_role_arn=arn:aws:iam::123:role/ChatOpsRole" \  -var='subnet_ids=["subnet-1","subnet-2"]' \  -var='security_group_ids=["sg-123"]'
```

ثم اربط **web_acl_id** في الـCloudFront Distribution أو عبر CLI:
```bash
aws cloudfront associate-distribution-web-acl --id <DIST_ID> --web-acl-arn $(terraform output -raw waf_acl_arn) --region us-east-1
```

## 4) تفعيل لوحة WebRTC
- اربط تدفق `/aif/ingest/webrtc` → OpenSearch index `aif-webrtc-*` بحقوله (jitter, packetsLost, jitterBufferDelay, jitterBufferTargetDelay).
- استورد `grafana/dashboards/webrtc_quality.json` أو ضعه في مجلد provisioning للداشبوردات.
