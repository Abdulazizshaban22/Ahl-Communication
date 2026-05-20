# -----------------------------
# SLO Burn-rate alarms (two-window) + Composite
# Error rate computed from ALB metrics: HTTPCode_Target_5XX_Count / RequestCount
# Burn rate = error_rate / error_budget, where error_budget = (100 - slo_target)%
# -----------------------------

# SNS Topic for alerts
resource "aws_sns_topic" "slo_alerts" {
  name = "ahla-slo-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  count     = var.sns_email == null ? 0 : 1
  topic_arn = aws_sns_topic.slo_alerts.arn
  protocol  = "email"
  endpoint  = var.sns_email
}

locals {
  error_budget = 100 - var.slo_target
}

# 1-hour burn-rate (aggressive)
resource "aws_cloudwatch_metric_alarm" "slo_burnrate_1h" {
  alarm_name          = "ahla-slo-burnrate-1h"
  alarm_description   = "High burn-rate over 1h window (consuming error budget too fast)."
  comparison_operator = "GreaterThanThreshold"
  threshold           = 2  # >2x error budget consumption
  evaluation_periods  = 60
  datapoints_to_alarm = 5
  treat_missing_data  = "missing"
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.slo_alerts.arn]

  metric_query {
    id          = "e5xx"
    expression  = "SEARCH('{AWS/ApplicationELB,LoadBalancer,TargetGroup} MetricName="HTTPCode_Target_5XX_Count" LoadBalancer="${var.alb_load_balancer}" TargetGroup="${var.alb_target_group}"', 'Sum', 60)"
    return_data = false
  }

  metric_query {
    id          = "req"
    expression  = "SEARCH('{AWS/ApplicationELB,LoadBalancer,TargetGroup} MetricName="RequestCount" LoadBalancer="${var.alb_load_balancer}" TargetGroup="${var.alb_target_group}"', 'Sum', 60)"
    return_data = false
  }

  metric_query {
    id          = "err_rate"
    expression  = "100 * (FILL(METRICS('e5xx'),0) / MAX([FILL(METRICS('req'),1)]))"
    label       = "ErrorRatePercent"
    return_data = false
  }

  metric_query {
    id          = "burn"
    expression  = "IF(local.error_budget > 0, METRICS('err_rate') / local.error_budget, 0)"
    label       = "BurnRate"
    return_data = true
  }
}

# 6-hour burn-rate (quiet/stable)
resource "aws_cloudwatch_metric_alarm" "slo_burnrate_6h" {
  alarm_name          = "ahla-slo-burnrate-6h"
  alarm_description   = "Elevated burn-rate over 6h window."
  comparison_operator = "GreaterThanThreshold"
  threshold           = 1
  evaluation_periods  = 72  # 72 * 5 min = 6h if using 5min period
  datapoints_to_alarm = 6
  treat_missing_data  = "missing"
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.slo_alerts.arn]
  period              = 300

  metric_query {
    id          = "e5xx6"
    expression  = "SEARCH('{AWS/ApplicationELB,LoadBalancer,TargetGroup} MetricName="HTTPCode_Target_5XX_Count" LoadBalancer="${var.alb_load_balancer}" TargetGroup="${var.alb_target_group}"', 'Sum', 300)"
    return_data = false
  }

  metric_query {
    id          = "req6"
    expression  = "SEARCH('{AWS/ApplicationELB,LoadBalancer,TargetGroup} MetricName="RequestCount" LoadBalancer="${var.alb_load_balancer}" TargetGroup="${var.alb_target_group}"', 'Sum', 300)"
    return_data = false
  }

  metric_query {
    id          = "err_rate6"
    expression  = "100 * (FILL(METRICS('e5xx6'),0) / MAX([FILL(METRICS('req6'),1)]))"
    label       = "ErrorRatePercent6h"
    return_data = false
  }

  metric_query {
    id          = "burn6"
    expression  = "IF(local.error_budget > 0, METRICS('err_rate6') / local.error_budget, 0)"
    label       = "BurnRate6h"
    return_data = true
  }
}

# Composite alarm: fire only if both windows indicate a breach
resource "aws_cloudwatch_composite_alarm" "slo_composite" {
  alarm_name        = "ahla-slo-burnrate-composite"
  alarm_description = "Multi-window multi-burn-rate composite (1h & 6h)."
  alarm_rule        = "ALARM(${aws_cloudwatch_metric_alarm.slo_burnrate_1h.alarm_name}) AND ALARM(${aws_cloudwatch_metric_alarm.slo_burnrate_6h.alarm_name})"
  alarm_actions     = [aws_sns_topic.slo_alerts.arn]
}
