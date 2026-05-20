
variable "region" { default = "me-central-1" }
variable "vpc_id" {}
variable "public_subnets"  { type = list(string) }
variable "private_subnets" { type = list(string) }
variable "domain_name" {}
variable "route53_zone_id" {}
variable "certificate_arn" {}
variable "alerts_email" {}

# ECR images
variable "img_chat_web" {}
variable "img_meet_web" {}
variable "img_chat_api" {}
variable "img_meet_api" {}
variable "img_emotion_engine" {}
variable "img_push_worker" {}

# Secrets (SSM ARNs)
variable "ssm_vapid_pub" {}
variable "ssm_vapid_priv" {}
