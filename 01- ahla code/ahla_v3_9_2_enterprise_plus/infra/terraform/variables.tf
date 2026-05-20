variable "project" { type = string  default = "ahla" }
variable "region"  { type = string  default = "eu-central-1" }

# CloudFront
variable "cloudfront_distribution_id" { type = string, default = null }
variable "attach_cf_web_acl" { type = bool, default = false }

# ALB (regional)
variable "alb_arn" { type = string, default = null }
variable "alb_load_balancer" { type = string }
variable "alb_tg_chat"  { type = string }
variable "alb_tg_meet"  { type = string }
variable "alb_tg_drive" { type = string }
variable "alb_tg_mail"  { type = string }

# SLO targets (percentage)
variable "slo_target_chat"  { type = number, default = 99.9 }
variable "slo_target_meet"  { type = number, default = 99.5 }
variable "slo_target_drive" { type = number, default = 99.9 }
variable "slo_target_mail"  { type = number, default = 99.9 }

# Alerts
variable "sns_email" { type = string, default = null }
