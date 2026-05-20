variable "name_prefix"   { type = string }
variable "service_name"  { type = string } # chat|meet|drive|mail
variable "metric_ns"     { type = string } # e.g., "Ahla"
variable "slo_target"    { type = number } # e.g., 0.999
variable "slo_period_days" { type = number } # e.g., 30
variable "sns_topic_arn" { type = string }
