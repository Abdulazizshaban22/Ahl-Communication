
variable "region" { default = "me-central-1" }
variable "vpc_id" {}
variable "public_subnets"  { type = list(string) }
variable "private_subnets" { type = list(string) }
variable "domain_name" {}
variable "route53_zone_id" {}
variable "certificate_arn" {}
variable "alerts_email" {}

# ECR images (core)
variable "img_chat_web" {}
variable "img_meet_web" {}
variable "img_chat_api" {}
variable "img_meet_api" {}
variable "img_emotion_engine" {}
variable "img_push_worker" {}

# Drive & Business
variable "img_drive_web" {}
variable "img_drive_api" {}
variable "img_business_web" {}
variable "img_business_api" {}

# Mail
variable "img_mail_web" {}
variable "img_mail_api" {}

# Secrets
variable "ssm_vapid_pub" {}
variable "ssm_vapid_priv" {}

# Mail providers
variable "mail_imap_host" {}
variable "mail_imap_port" { default = 993 }
variable "mail_imap_secure" { default = true }
variable "mail_smtp_host" {}
variable "mail_smtp_port" { default = 587 }
variable "mail_smtp_secure" { default = true }
variable "ssm_mail_user" {}
variable "ssm_mail_pass" {}
