variable "region"          { type = string }
variable "name_prefix"     { type = string  default = "ahla" }
variable "sns_topic_arn"   { type = string  default = "" } # reuse existing
# Jira/Slack/Notion
variable "jira_url"        { type = string  default = "" }
variable "jira_email"      { type = string  default = "" }
variable "jira_api_token"  { type = string  default = "" }
variable "jira_project_key"{ type = string  default = "OPS" }
variable "slack_webhook"   { type = string  default = "" }
variable "notion_token"    { type = string  default = "" }
variable "notion_parent"   { type = string  default = "" }
# Grafana silence sync
variable "grafana_url"     { type = string  default = "" }
variable "grafana_token"   { type = string  default = "" }
variable "git_silence_url" { type = string  default = "" }
variable "s3_bucket"       { type = string  default = "" }
variable "s3_key"          { type = string  default = "" }
variable "silence_sync_cron" { type = string default = "" } # e.g., cron(0/15 * * * ? *)
