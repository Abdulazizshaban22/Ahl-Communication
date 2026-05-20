variable "region" { type = string }
variable "name_prefix" { type = string }
variable "login_path" { type = string  default = "/auth/login" }
variable "register_path" { type = string default = "/auth/register" }
variable "atp_success_codes" { type = list(number) default = [200,204,302] }
variable "atp_failure_codes" { type = list(number) default = [400,401,403] }

variable "slack_team_id" { type = string }
variable "slack_channel_id" { type = string }
variable "chatops_iam_role_arn" { type = string }

variable "subnet_ids" { type = list(string) }
variable "security_group_ids" { type = list(string) }

variable "sns_topic_arn" { type = string }

# ALB anomaly example
variable "alb_name" { type = string }
variable "alb_target_group" { type = string }
