data "archive_file" "waf_switch_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda/waf_switch"
  output_path = "${path.module}/../lambda/waf_switch.zip"
}

resource "aws_lambda_function" "waf_switch" {
  function_name = "${var.project}-waf-count2block"
  role          = aws_iam_role.waf_switch_role.arn
  handler       = "main.handler"
  runtime       = "python3.12"
  filename      = data.archive_file.waf_switch_zip.output_path
  timeout       = 60

  environment {
    variables = {
      CF_WEB_ACL_ARN     = var.cf_web_acl_arn
      ALB_WEB_ACL_ARN    = var.alb_web_acl_arn
      ENABLE_AUTO_BLOCK  = tostring(var.enable_auto_block)
    }
  }
}

# Schedule after X hours (disabled by default — enable when ready)
resource "aws_cloudwatch_event_rule" "waf_switch_rule" {
  name                = "${var.project}-waf-switch-schedule"
  schedule_expression = "rate(${var.auto_block_after_hours} hours)"
  is_enabled          = false
}

resource "aws_cloudwatch_event_target" "waf_switch_target" {
  rule = aws_cloudwatch_event_rule.waf_switch_rule.name
  arn  = aws_lambda_function.waf_switch.arn
}

resource "aws_lambda_permission" "allow_events" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.waf_switch.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.waf_switch_rule.arn
}
