resource "aws_sns_topic" "slo_alerts" { name = "${var.project}-slo-alerts" }
resource "aws_sns_topic_subscription" "email" {
  count     = var.sns_email == null ? 0 : 1
  topic_arn = aws_sns_topic.slo_alerts.arn
  protocol  = "email"
  endpoint  = var.sns_email
}

# helper locals
locals {
  budget_chat  = 100 - var.slo_target_chat
  budget_meet  = 100 - var.slo_target_meet
  budget_drive = 100 - var.slo_target_drive
  budget_mail  = 100 - var.slo_target_mail
}

# Macro-like module replacement: define a small template using 'for_each' over services
# but to keep it simple and explicit, we define four services blocks.

# CHAT
resource "aws_cloudwatch_metric_alarm" "burn_1h_chat" {
  alarm_name          = "${var.project}-burn-1h-chat"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 2
  evaluation_periods  = 60
  datapoints_to_alarm = 5
  treat_missing_data  = "missing"
  alarm_actions       = [aws_sns_topic.slo_alerts.arn]

  metric_query { id="e5xx"; expression="SEARCH('{AWS/ApplicationELB,LoadBalancer,TargetGroup} MetricName="HTTPCode_Target_5XX_Count" LoadBalancer="${var.alb_load_balancer}" TargetGroup="${var.alb_tg_chat}"','Sum',60)"; return_data=false }
  metric_query { id="req";  expression="SEARCH('{AWS/ApplicationELB,LoadBalancer,TargetGroup} MetricName="RequestCount" LoadBalancer="${var.alb_load_balancer}" TargetGroup="${var.alb_tg_chat}"','Sum',60)"; return_data=false }
  metric_query { id="err_rate"; expression="100 * (FILL(METRICS('e5xx'),0) / MAX([FILL(METRICS('req'),1)]))"; return_data=false }
  metric_query { id="burn";     expression="IF(${local.budget_chat} > 0, METRICS('err_rate') / ${local.budget_chat}, 0)"; return_data=true }
}

resource "aws_cloudwatch_metric_alarm" "burn_6h_chat" {
  alarm_name          = "${var.project}-burn-6h-chat"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 1
  evaluation_periods  = 72
  datapoints_to_alarm = 6
  period              = 300
  treat_missing_data  = "missing"
  alarm_actions       = [aws_sns_topic.slo_alerts.arn]

  metric_query { id="e5xx6"; expression="SEARCH('{AWS/ApplicationELB,LoadBalancer,TargetGroup} MetricName="HTTPCode_Target_5XX_Count" LoadBalancer="${var.alb_load_balancer}" TargetGroup="${var.alb_tg_chat}"','Sum',300)"; return_data=false }
  metric_query { id="req6";  expression="SEARCH('{AWS/ApplicationELB,LoadBalancer,TargetGroup} MetricName="RequestCount" LoadBalancer="${var.alb_load_balancer}" TargetGroup="${var.alb_tg_chat}"','Sum',300)"; return_data=false }
  metric_query { id="err_rate6"; expression="100 * (FILL(METRICS('e5xx6'),0) / MAX([FILL(METRICS('req6'),1)]))"; return_data=false }
  metric_query { id="burn6";     expression="IF(${local.budget_chat} > 0, METRICS('err_rate6') / ${local.budget_chat}, 0)"; return_data=true }
}

resource "aws_cloudwatch_composite_alarm" "comp_chat" {
  alarm_name   = "${var.project}-slo-comp-chat"
  alarm_rule   = "ALARM(${aws_cloudwatch_metric_alarm.burn_1h_chat.alarm_name}) AND ALARM(${aws_cloudwatch_metric_alarm.burn_6h_chat.alarm_name})"
  alarm_actions= [aws_sns_topic.slo_alerts.arn]
}

# MEET
resource "aws_cloudwatch_metric_alarm" "burn_1h_meet" {
  alarm_name          = "${var.project}-burn-1h-meet"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 2
  evaluation_periods  = 60
  datapoints_to_alarm = 5
  treat_missing_data  = "missing"
  alarm_actions       = [aws_sns_topic.slo_alerts.arn]

  metric_query { id="e5xx"; expression="SEARCH('{AWS/ApplicationELB,LoadBalancer,TargetGroup} MetricName="HTTPCode_Target_5XX_Count" LoadBalancer="${var.alb_load_balancer}" TargetGroup="${var.alb_tg_meet}"','Sum',60)"; return_data=false }
  metric_query { id="req";  expression="SEARCH('{AWS/ApplicationELB,LoadBalancer,TargetGroup} MetricName="RequestCount" LoadBalancer="${var.alb_load_balancer}" TargetGroup="${var.alb_tg_meet}"','Sum',60)"; return_data=false }
  metric_query { id="err_rate"; expression="100 * (FILL(METRICS('e5xx'),0) / MAX([FILL(METRICS('req'),1)]))"; return_data=false }
  metric_query { id="burn";     expression="IF(${local.budget_meet} > 0, METRICS('err_rate') / ${local.budget_meet}, 0)"; return_data=true }
}

resource "aws_cloudwatch_metric_alarm" "burn_6h_meet" {
  alarm_name          = "${var.project}-burn-6h-meet"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 1
  evaluation_periods  = 72
  datapoints_to_alarm = 6
  period              = 300
  treat_missing_data  = "missing"
  alarm_actions       = [aws_sns_topic.slo_alerts.arn]

  metric_query { id="e5xx6"; expression="SEARCH('{AWS/ApplicationELB,LoadBalancer,TargetGroup} MetricName="HTTPCode_Target_5XX_Count" LoadBalancer="${var.alb_load_balancer}" TargetGroup="${var.alb_tg_meet}"','Sum',300)"; return_data=false }
  metric_query { id="req6";  expression="SEARCH('{AWS/ApplicationELB,LoadBalancer,TargetGroup} MetricName="RequestCount" LoadBalancer="${var.alb_load_balancer}" TargetGroup="${var.alb_tg_meet}"','Sum',300)"; return_data=false }
  metric_query { id="err_rate6"; expression="100 * (FILL(METRICS('e5xx6'),0) / MAX([FILL(METRICS('req6'),1)]))"; return_data=false }
  metric_query { id="burn6";     expression="IF(${local.budget_meet} > 0, METRICS('err_rate6') / ${local.budget_meet}, 0)"; return_data=true }
}

resource "aws_cloudwatch_composite_alarm" "comp_meet" {
  alarm_name   = "${var.project}-slo-comp-meet"
  alarm_rule   = "ALARM(${aws_cloudwatch_metric_alarm.burn_1h_meet.alarm_name}) AND ALARM(${aws_cloudwatch_metric_alarm.burn_6h_meet.alarm_name})"
  alarm_actions= [aws_sns_topic.slo_alerts.arn]
}

# DRIVE
resource "aws_cloudwatch_metric_alarm" "burn_1h_drive" {
  alarm_name          = "${var.project}-burn-1h-drive"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 2
  evaluation_periods  = 60
  datapoints_to_alarm = 5
  treat_missing_data  = "missing"
  alarm_actions       = [aws_sns_topic.slo_alerts.arn]

  metric_query { id="e5xx"; expression="SEARCH('{AWS/ApplicationELB,LoadBalancer,TargetGroup} MetricName="HTTPCode_Target_5XX_Count" LoadBalancer="${var.alb_load_balancer}" TargetGroup="${var.alb_tg_drive}"','Sum',60)"; return_data=false }
  metric_query { id="req";  expression="SEARCH('{AWS/ApplicationELB,LoadBalancer,TargetGroup} MetricName="RequestCount" LoadBalancer="${var.alb_load_balancer}" TargetGroup="${var.alb_tg_drive}"','Sum',60)"; return_data=false }
  metric_query { id="err_rate"; expression="100 * (FILL(METRICS('e5xx'),0) / MAX([FILL(METRICS('req'),1)]))"; return_data=false }
  metric_query { id="burn";     expression="IF(${local.budget_drive} > 0, METRICS('err_rate') / ${local.budget_drive}, 0)"; return_data=true }
}

resource "aws_cloudwatch_metric_alarm" "burn_6h_drive" {
  alarm_name          = "${var.project}-burn-6h-drive"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 1
  evaluation_periods  = 72
  datapoints_to_alarm = 6
  period              = 300
  treat_missing_data  = "missing"
  alarm_actions       = [aws_sns_topic.slo_alerts.arn]

  metric_query { id="e5xx6"; expression="SEARCH('{AWS/ApplicationELB,LoadBalancer,TargetGroup} MetricName="HTTPCode_Target_5XX_Count" LoadBalancer="${var.alb_load_balancer}" TargetGroup="${var.alb_tg_drive}"','Sum',300)"; return_data=false }
  metric_query { id="req6";  expression="SEARCH('{AWS/ApplicationELB,LoadBalancer,TargetGroup} MetricName="RequestCount" LoadBalancer="${var.alb_load_balancer}" TargetGroup="${var.alb_tg_drive}"','Sum',300)"; return_data=false }
  metric_query { id="err_rate6"; expression="100 * (FILL(METRICS('e5xx6'),0) / MAX([FILL(METRICS('req6'),1)]))"; return_data=false }
  metric_query { id="burn6";     expression="IF(${local.budget_drive} > 0, METRICS('err_rate6') / ${local.budget_drive}, 0)"; return_data=true }
}

resource "aws_cloudwatch_composite_alarm" "comp_drive" {
  alarm_name   = "${var.project}-slo-comp-drive"
  alarm_rule   = "ALARM(${aws_cloudwatch_metric_alarm.burn_1h_drive.alarm_name}) AND ALARM(${aws_cloudwatch_metric_alarm.burn_6h_drive.alarm_name})"
  alarm_actions= [aws_sns_topic.slo_alerts.arn]
}

# MAIL
resource "aws_cloudwatch_metric_alarm" "burn_1h_mail" {
  alarm_name          = "${var.project}-burn-1h-mail"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 2
  evaluation_periods  = 60
  datapoints_to_alarm = 5
  treat_missing_data  = "missing"
  alarm_actions       = [aws_sns_topic.slo_alerts.arn]

  metric_query { id="e5xx"; expression="SEARCH('{AWS/ApplicationELB,LoadBalancer,TargetGroup} MetricName="HTTPCode_Target_5XX_Count" LoadBalancer="${var.alb_load_balancer}" TargetGroup="${var.alb_tg_mail}"','Sum',60)"; return_data=false }
  metric_query { id="req";  expression="SEARCH('{AWS/ApplicationELB,LoadBalancer,TargetGroup} MetricName="RequestCount" LoadBalancer="${var.alb_load_balancer}" TargetGroup="${var.alb_tg_mail}"','Sum',60)"; return_data=false }
  metric_query { id="err_rate"; expression="100 * (FILL(METRICS('e5xx'),0) / MAX([FILL(METRICS('req'),1)]))"; return_data=false }
  metric_query { id="burn";     expression="IF(${local.budget_mail} > 0, METRICS('err_rate') / ${local.budget_mail}, 0)"; return_data=true }
}

resource "aws_cloudwatch_metric_alarm" "burn_6h_mail" {
  alarm_name          = "${var.project}-burn-6h-mail"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 1
  evaluation_periods  = 72
  datapoints_to_alarm = 6
  period              = 300
  treat_missing_data  = "missing"
  alarm_actions       = [aws_sns_topic.slo_alerts.arn]

  metric_query { id="e5xx6"; expression="SEARCH('{AWS/ApplicationELB,LoadBalancer,TargetGroup} MetricName="HTTPCode_Target_5XX_Count" LoadBalancer="${var.alb_load_balancer}" TargetGroup="${var.alb_tg_mail}"','Sum',300)"; return_data=false }
  metric_query { id="req6";  expression="SEARCH('{AWS/ApplicationELB,LoadBalancer,TargetGroup} MetricName="RequestCount" LoadBalancer="${var.alb_load_balancer}" TargetGroup="${var.alb_tg_mail}"','Sum',300)"; return_data=false }
  metric_query { id="err_rate6"; expression="100 * (FILL(METRICS('e5xx6'),0) / MAX([FILL(METRICS('req6'),1)]))"; return_data=false }
  metric_query { id="burn6";     expression="IF(${local.budget_mail} > 0, METRICS('err_rate6') / ${local.budget_mail}, 0)"; return_data=true }
}

resource "aws_cloudwatch_composite_alarm" "comp_mail" {
  alarm_name   = "${var.project}-slo-comp-mail"
  alarm_rule   = "ALARM(${aws_cloudwatch_metric_alarm.burn_1h_mail.alarm_name}) AND ALARM(${aws_cloudwatch_metric_alarm.burn_6h_mail.alarm_name})"
  alarm_actions= [aws_sns_topic.slo_alerts.arn]
}

# Platform composites
resource "aws_cloudwatch_composite_alarm" "platform_any" {
  alarm_name   = "${var.project}-platform-degraded-any"
  alarm_rule   = "ALARM(${aws_cloudwatch_composite_alarm.comp_chat.alarm_name}) OR ALARM(${aws_cloudwatch_composite_alarm.comp_meet.alarm_name}) OR ALARM(${aws_cloudwatch_composite_alarm.comp_drive.alarm_name}) OR ALARM(${aws_cloudwatch_composite_alarm.comp_mail.alarm_name})"
  alarm_actions= [aws_sns_topic.slo_alerts.arn]
}

resource "aws_cloudwatch_composite_alarm" "platform_critical_all" {
  alarm_name   = "${var.project}-platform-critical-all"
  alarm_rule   = "ALARM(${aws_cloudwatch_composite_alarm.comp_chat.alarm_name}) AND ALARM(${aws_cloudwatch_composite_alarm.comp_meet.alarm_name}) AND ALARM(${aws_cloudwatch_composite_alarm.comp_drive.alarm_name}) AND ALARM(${aws_cloudwatch_composite_alarm.comp_mail.alarm_name})"
  alarm_actions= [aws_sns_topic.slo_alerts.arn]
}

output "sns_topic_arn" { value = aws_sns_topic.slo_alerts.arn }
