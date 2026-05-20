# Optional Slack wiring via AWS Chatbot
resource "aws_chatbot_slack_channel_configuration" "ops" {
  count                 = var.slack_workspace_id == null ? 0 : 1
  name                  = "${var.project}-${var.slack_channel_name}"
  slack_channel_id      = var.slack_channel_id
  slack_workspace_id    = var.slack_workspace_id
  iam_role_arn          = aws_iam_role.waf_switch_role.arn
  logging_level         = "ERROR"
  guardrail_policies    = []
  sns_topics            = [var.sns_topic_arn]
}
output "chatops_arn" {
  value       = try(aws_chatbot_slack_channel_configuration.ops[0].chat_configuration_arn, null)
  description = "Slack Chatbot configuration ARN (if created)"
}
