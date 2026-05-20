terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.60.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# --- Modules ---
module "waf_acl" {
  source              = "./modules/waf_acl"
  name_prefix         = var.name_prefix
  cf_scope_region     = "us-east-1" # CloudFront WAFv2 is GLOBAL region
  login_path          = var.login_path
  register_path       = var.register_path
  atp_success_codes   = var.atp_success_codes
  atp_failure_codes   = var.atp_failure_codes
}

module "chatops" {
  source            = "./modules/chatops"
  name_prefix       = var.name_prefix
  slack_team_id     = var.slack_team_id
  slack_channel_id  = var.slack_channel_id
  iam_role_arn      = var.chatops_iam_role_arn
}

module "msk_serverless" {
  source               = "./modules/msk_serverless"
  name_prefix          = var.name_prefix
  subnet_ids           = var.subnet_ids
  security_group_ids   = var.security_group_ids
}

# Example alarm (Anomaly Detection) — p95 TargetResponseTime of ALB
module "anomaly_alarms" {
  source                = "./modules/anomaly_alarms"
  name_prefix           = var.name_prefix
  alb_name              = var.alb_name
  alb_target_group      = var.alb_target_group
  sns_topic_arn         = var.sns_topic_arn
  region                = var.region
}

output "waf_web_acl_arn" {
  value = module.waf_acl.web_acl_arn
}

# For CloudFront, pass this to aws_cloudfront_distribution.web_acl_id (arn form)
output "cloudfront_waf_web_acl_for_distribution" {
  value = module.waf_acl.web_acl_arn
}
