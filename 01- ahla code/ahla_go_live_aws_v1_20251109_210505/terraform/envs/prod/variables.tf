
variable "region" { default = "me-central-1" }
variable "vpc_id" {}
variable "public_subnets"  { type = list(string) }
variable "private_subnets" { type = list(string) }
variable "domain_name" {}
variable "route53_zone_id" {}
variable "certificate_arn" {}

# Container images (ECR ARNs or repo:tag)
variable "img_chat_web"      {}
variable "img_chat_api"      {}
variable "img_moments_api"   {}
variable "img_emotion_api"   {}
variable "img_voice_api"     {}
variable "img_push_worker"   {}

# Secrets (SSM parameter ARNs)
variable "ssm_vapid_pub"  {}
variable "ssm_vapid_priv" {}
