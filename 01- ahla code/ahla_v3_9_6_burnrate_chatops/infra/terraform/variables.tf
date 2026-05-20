variable "region"            { type = string }
variable "name_prefix"       { type = string  default = "ahla" }
variable "sns_topic_arn"     { type = string  default = "" } # optional existing
variable "slack_team_id"     { type = string }
variable "slack_channel_id"  { type = string }
variable "chatops_iam_role_arn" { type = string }

# CloudWatch metric namespace for Ahla services
variable "metric_ns"         { type = string  default = "Ahla" }

# SLO targets (availability, e.g., 0.999)
variable "slo_target_chat"   { type = number  default = 0.999 }
variable "slo_target_meet"   { type = number  default = 0.995 }
variable "slo_target_drive"  { type = number  default = 0.999 }
variable "slo_target_mail"   { type = number  default = 0.999 }
variable "slo_period_days"   { type = number  default = 30 }
