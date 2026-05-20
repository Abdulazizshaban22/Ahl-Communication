terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = ">= 5.60.0" }
  }
}

variable "name_prefix" { type = string }
variable "sns_topic_arn" { type = string }
variable "maintenance_schedule_cron_start" { type = string } # e.g., cron(0 23 ? * FRI *)
variable "maintenance_schedule_cron_end"   { type = string } # e.g., cron(0 0 ? * SAT *)

# Custom metric to indicate maintenance mode (1=on, 0=off)
resource "aws_cloudwatch_metric_alarm" "maintenance_mode" {
  alarm_name          = "${var.name_prefix}-maintenance-mode"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 0.5
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  treat_missing_data  = "notBreaching"
  namespace           = "Ahla/OPS"
  metric_name         = "MaintenanceMode"
  period              = 60
  statistic           = "Average"
}

# Lambda that toggles metric value 1/0
resource "aws_iam_role" "toggle_role" {
  name = "${var.name_prefix}-maintenance-toggle-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{Effect:"Allow",Principal:{Service:"lambda.amazonaws.com"},Action:"sts:AssumeRole"}]
  })
}

resource "aws_iam_role_policy" "toggle_policy" {
  name = "${var.name_prefix}-maintenance-toggle-policy"
  role = aws_iam_role.toggle_role.id
  policy = jsonencode({
    Version:"2012-10-17",
    Statement:[
      {Effect:"Allow", Action:["cloudwatch:PutMetricData"], Resource:"*"},
      {Effect:"Allow", Action:["logs:CreateLogGroup","logs:CreateLogStream","logs:PutLogEvents"], Resource:"*"}
    ]
  })
}

data "archive_file" "toggle_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "toggle" {
  function_name = "${var.name_prefix}-maintenance-toggle"
  role          = aws_iam_role.toggle_role.arn
  handler       = "main.handler"
  runtime       = "python3.12"
  filename      = data.archive_file.toggle_zip.output_path
  timeout       = 10

  environment {
    variables = { NAMESPACE = "Ahla/OPS" }
  }
}

# EventBridge schedules to turn ON/OFF maintenance metric
resource "aws_cloudwatch_event_rule" "start" {
  name                = "${var.name_prefix}-maintenance-start"
  schedule_expression = var.maintenance_schedule_cron_start
}

resource "aws_cloudwatch_event_rule" "end" {
  name                = "${var.name_prefix}-maintenance-end"
  schedule_expression = var.maintenance_schedule_cron_end
}

resource "aws_cloudwatch_event_target" "start_t" {
  rule = aws_cloudwatch_event_rule.start.name
  arn  = aws_lambda_function.toggle.arn
  input = jsonencode({"value":1})
}
resource "aws_cloudwatch_event_target" "end_t" {
  rule = aws_cloudwatch_event_rule.end.name
  arn  = aws_lambda_function.toggle.arn
  input = jsonencode({"value":0})
}

resource "aws_lambda_permission" "allow_events_start" {
  statement_id  = "AllowStart"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.toggle.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.start.arn
}
resource "aws_lambda_permission" "allow_events_end" {
  statement_id  = "AllowEnd"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.toggle.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.end.arn
}

# Example: Suppress actions of composite alarms during maintenance
# Input list of composite alarm ARNs to suppress
variable "composite_alarm_arns" { type = list(string) }

resource "aws_cloudwatch_composite_alarm" "suppressed_example" {
  count               = length(var.composite_alarm_arns) == 0 ? 0 : length(var.composite_alarm_arns)
  alarm_name          = "${var.name_prefix}-suppressed-${count.index}"
  alarm_description   = "Wrapper with suppression (example placeholder)"
  alarm_rule          = "ALARM("placeholder-alarm-name")"
  actions_suppressor  = aws_cloudwatch_metric_alarm.maintenance_mode.arn
  actions_suppressor_wait_period = 0
  actions_suppressor_extension_period = 300
}
