variable "project" { type = string  default = "ahla" }
variable "region"  { type = string  default = "eu-central-1" }

# WAF
variable "cf_web_acl_arn" { type = string }   # CLOUDFRONT scope (us-east-1)
variable "alb_web_acl_arn" { type = string }  # REGIONAL scope
variable "auto_block_after_hours" { type = number default = 24 }
variable "enable_auto_block" { type = bool default = true }

# SLO / ALB dims
variable "alb_load_balancer" { type = string }
variable "alb_tg_chat"  { type = string }
variable "alb_tg_meet"  { type = string }
variable "alb_tg_drive" { type = string }
variable "alb_tg_mail"  { type = string }

# SNS + ChatOps
variable "sns_topic_arn" { type = string } # From previous step v3.9.2
variable "slack_workspace_id" { type = string default = null }
variable "slack_channel_id"   { type = string default = null }
variable "slack_channel_name" { type = string default = "ahla-ops" }

# OpenSearch
variable "opensearch_endpoint" { type = string default = null } # https://xxxxx.us-east-1.aoss.amazonaws.com or ES domain endpoint
variable "opensearch_index"    { type = string default = "ahla-incidents" }
variable "opensearch_auth_mode"{ type = string default = "iam" } # iam|basic
variable "opensearch_basic_user" { type = string default = null }
variable "opensearch_basic_pass" { type = string default = null }

# Apdex SLO targets (for anomalies optional reference)
variable "slo_target_chat"  { type = number default = 99.9 }
variable "slo_target_meet"  { type = number default = 99.5 }
variable "slo_target_drive" { type = number default = 99.9 }
variable "slo_target_mail"  { type = number default = 99.9 }
