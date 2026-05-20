
# Ahla Suite v1.1 — AWS (ElastiCache + Alarms + TURN)
- Redis: ElastiCache داخل الشبكة الخاصة
- Alarms: CPU/Mem لكل خدمة + ALB 5xx (SNS Email)
- TURN: NLB على 3478 UDP/TCP مع نطاق turn.SUBDOMAIN

## prod.tfvars (نموذج)
region         = "me-central-1"
vpc_id         = "vpc-xxxxxxxx"
public_subnets = ["subnet-aaaa","subnet-bbbb"]
private_subnets= ["subnet-cccc","subnet-dddd"]
domain_name    = "ahla.example.com"
route53_zone_id= "Z123456789"
certificate_arn= "arn:aws:acm:me-central-1:1111:certificate/xxxx"
alerts_email   = "you@example.com"

img_chat_web      = "1111.dkr.ecr.me-central-1.amazonaws.com/ahla-chat-web:prod"
img_meet_web      = "1111.dkr.ecr.me-central-1.amazonaws.com/ahla-meet-web:prod"
img_chat_api      = "1111.dkr.ecr.me-central-1.amazonaws.com/ahla-chat-api:prod"
img_meet_api      = "1111.dkr.ecr.me-central-1.amazonaws.com/ahla-meet-api:prod"
img_emotion_engine= "1111.dkr.ecr.me-central-1.amazonaws.com/ahla-emotion-engine:prod"
img_push_worker   = "1111.dkr.ecr.me-central-1.amazonaws.com/ahla-push-worker:prod"

ssm_vapid_pub  = "arn:aws:ssm:me-central-1:1111:parameter/ahla/vapid/public"
ssm_vapid_priv = "arn:aws:ssm:me-central-1:1111:parameter/ahla/vapid/private"
