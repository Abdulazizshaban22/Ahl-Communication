resource "aws_chatbot_slack_channel_configuration" "this" {
  configuration_name = "${var.name_prefix}-slack"
  iam_role_arn       = var.iam_role_arn
  slack_channel_id   = var.slack_channel_id
  slack_team_id      = var.slack_team_id
  logging_level      = "ERROR"
}
output "chatops_config_name" { value = aws_chatbot_slack_channel_configuration.this.configuration_name }
