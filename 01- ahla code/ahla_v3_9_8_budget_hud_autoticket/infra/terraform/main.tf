terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = ">= 5.60.0" }
    archive = { source = "hashicorp/archive", version = ">= 2.6.0" }
  }
}

provider "aws" { region = var.region }

# SNS topic for SLO alerts (reuse if provided)
resource "aws_sns_topic" "slo_alerts" {
  count = var.sns_topic_arn == "" ? 1 : 0
  name  = "${var.name_prefix}-slo-alerts"
}
locals { slo_sns = var.sns_topic_arn != "" ? var.sns_topic_arn : aws_sns_topic.slo_alerts[0].arn }

# IAM for Lambdas
resource "aws_iam_role" "lambda_role" {
  name = "${var.name_prefix}-autoticket-role"
  assume_role_policy = jsonencode({
    Version:"2012-10-17",
    Statement:[{Effect:"Allow",Principal:{Service:"lambda.amazonaws.com"},Action:"sts:AssumeRole"}]
  })
}
resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.name_prefix}-autoticket-policy"
  role = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version:"2012-10-17",
    Statement:[
      {Effect:"Allow",Action:["logs:CreateLogGroup","logs:CreateLogStream","logs:PutLogEvents"],Resource:"*"},
      {Effect:"Allow",Action:["s3:GetObject"],Resource:"*"}
    ]
  })
}

data "archive_file" "auto_ticket_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda/auto_ticket"
  output_path = "${path.module}/auto_ticket.zip"
}
resource "aws_lambda_function" "auto_ticket" {
  function_name = "${var.name_prefix}-auto-ticket"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  filename      = data.archive_file.auto_ticket_zip.output_path
  timeout       = 30
  environment {
    variables = {
      JIRA_URL          = var.jira_url
      JIRA_EMAIL        = var.jira_email
      JIRA_API_TOKEN    = var.jira_api_token
      JIRA_PROJECT_KEY  = var.jira_project_key
      SLACK_WEBHOOK     = var.slack_webhook
      NOTION_TOKEN      = var.notion_token
      NOTION_PARENT     = var.notion_parent
    }
  }
}

resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowSNSTrigger"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auto_ticket.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = local.slo_sns
}
resource "aws_sns_topic_subscription" "auto_ticket_sub" {
  topic_arn = local.slo_sns
  protocol  = "lambda"
  endpoint  = aws_lambda_function.auto_ticket.arn
}

# Silence Sync
data "archive_file" "silence_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda/silence_sync"
  output_path = "${path.module}/silence_sync.zip"
}
resource "aws_lambda_function" "silence_sync" {
  function_name = "${var.name_prefix}-silence-sync"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  filename      = data.archive_file.silence_zip.output_path
  timeout       = 30
  environment {
    variables = {
      GRAFANA_URL   = var.grafana_url
      GRAFANA_TOKEN = var.grafana_token
      GIT_SILENCE_URL = var.git_silence_url
      S3_BUCKET     = var.s3_bucket
      S3_KEY        = var.s3_key
    }
  }
}

# Schedule Silence Sync (optional)
resource "aws_cloudwatch_event_rule" "silence_schedule" {
  count = var.silence_sync_cron == "" ? 0 : 1
  name  = "${var.name_prefix}-silence-sync"
  schedule_expression = var.silence_sync_cron
}
resource "aws_cloudwatch_event_target" "silence_target" {
  count = var.silence_sync_cron == "" ? 0 : 1
  rule  = aws_cloudwatch_event_rule.silence_schedule[0].name
  arn   = aws_lambda_function.silence_sync.arn
}
resource "aws_lambda_permission" "allow_events" {
  count         = var.silence_sync_cron == "" ? 0 : 1
  statement_id  = "AllowEvents"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.silence_sync.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.silence_schedule[0].arn
}

output "sns_topic_arn" { value = local.slo_sns }
output "auto_ticket_function" { value = aws_lambda_function.auto_ticket.function_name }
output "silence_sync_function" { value = aws_lambda_function.silence_sync.function_name }
