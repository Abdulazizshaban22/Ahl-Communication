terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.60.0"
    }
  }
}

provider "aws" { region = var.region }

# SNS topic (use existing if provided)
resource "aws_sns_topic" "slo_alerts" {
  count = var.sns_topic_arn == "" ? 1 : 0
  name  = "${var.name_prefix}-slo-alerts"
}

locals {
  slo_sns_topic_arn = var.sns_topic_arn != "" ? var.sns_topic_arn : aws_sns_topic.slo_alerts[0].arn
}

# ChatOps (Slack via AWS Chatbot)
module "chatops" {
  source            = "./modules/chatops"
  name_prefix       = var.name_prefix
  slack_team_id     = var.slack_team_id
  slack_channel_id  = var.slack_channel_id
  iam_role_arn      = var.chatops_iam_role_arn
  sns_topic_arn     = local.slo_sns_topic_arn
}

# Create burn‑rate SLO alerting for each service
module "slo_chat" {
  source          = "./modules/slo_burnrate"
  name_prefix     = var.name_prefix
  service_name    = "chat"
  metric_ns       = var.metric_ns
  slo_target      = var.slo_target_chat
  slo_period_days = var.slo_period_days
  sns_topic_arn   = local.slo_sns_topic_arn
}

module "slo_meet" {
  source          = "./modules/slo_burnrate"
  name_prefix     = var.name_prefix
  service_name    = "meet"
  metric_ns       = var.metric_ns
  slo_target      = var.slo_target_meet
  slo_period_days = var.slo_period_days
  sns_topic_arn   = local.slo_sns_topic_arn
}

module "slo_drive" {
  source          = "./modules/slo_burnrate"
  name_prefix     = var.name_prefix
  service_name    = "drive"
  metric_ns       = var.metric_ns
  slo_target      = var.slo_target_drive
  slo_period_days = var.slo_period_days
  sns_topic_arn   = local.slo_sns_topic_arn
}

module "slo_mail" {
  source          = "./modules/slo_burnrate"
  name_prefix     = var.name_prefix
  service_name    = "mail"
  metric_ns       = var.metric_ns
  slo_target      = var.slo_target_mail
  slo_period_days = var.slo_period_days
  sns_topic_arn   = local.slo_sns_topic_arn
}

output "sns_topic_arn" { value = local.slo_sns_topic_arn }
output "chatops_configuration_name" { value = module.chatops.chatops_config_name }
