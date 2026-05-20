# We assume two CloudWatch metrics exist per service:
#  - {metric_ns}/{Service}/Requests (Sum)
#  - {metric_ns}/{Service}/Errors   (Sum)

locals {
  ns        = var.metric_ns
  svc_uc    = upper(var.service_name)
  svc_name  = var.service_name
  ebudg     = 1 - var.slo_target  # error budget fraction
}

# 1) FAST pair — 5m & 1h with 2% monthly budget (burn rate ~14.4 for 30d SLO 99.9%)
#    thresholds are encoded directly as burn rates to avoid % math in operator heads.

# SHORT window 5m
resource "aws_cloudwatch_metric_alarm" "fast_short" {
  alarm_name          = "${var.name_prefix}-${var.service_name}-br-fast-5m"
  alarm_description   = "Fast burn (5m) — high burn rate indicates rapid budget consumption"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 14.4  # default per SRE workbook (2% in 1h, evaluated short) 
  evaluation_periods  = 1
  period              = 300
  treat_missing_data  = "missing"
  alarm_actions       = [var.sns_topic_arn]

  metric_query { id = "e" metric { namespace = "${local.ns}/${local.svc_uc}" metric_name = "Errors"   stat = "Sum" period = 300 } }
  metric_query { id = "r" metric { namespace = "${local.ns}/${local.svc_uc}" metric_name = "Requests" stat = "Sum" period = 300 } }
  metric_query { id = "br" expression = "(e / r) / ${local.ebudg}" label = "burn_rate_5m" return_data = true }
}

# LONG window 1h
resource "aws_cloudwatch_metric_alarm" "fast_long" {
  alarm_name          = "${var.name_prefix}-${var.service_name}-br-fast-1h"
  alarm_description   = "Fast burn (1h) — sustained rapid budget consumption"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 14.4
  evaluation_periods  = 1
  period              = 3600
  treat_missing_data  = "missing"
  alarm_actions       = [var.sns_topic_arn]

  metric_query { id = "e" metric { namespace = "${local.ns}/${local.svc_uc}" metric_name = "Errors"   stat = "Sum" period = 3600 } }
  metric_query { id = "r" metric { namespace = "${local.ns}/${local.svc_uc}" metric_name = "Requests" stat = "Sum" period = 3600 } }
  metric_query { id = "br" expression = "(e / r) / ${local.ebudg}" label = "burn_rate_1h" return_data = true }
}

# Composite: fire only when BOTH windows breach (reduce noise)
resource "aws_cloudwatch_composite_alarm" "fast_pair" {
  alarm_name        = "${var.name_prefix}-${var.service_name}-br-fast-pair"
  alarm_description = "Multi‑window burn (5m&1h) — page immediately"
  alarm_rule        = "ALARM(${aws_cloudwatch_metric_alarm.fast_short.alarm_name}) AND ALARM(${aws_cloudwatch_metric_alarm.fast_long.alarm_name})"
  alarm_actions     = [var.sns_topic_arn]
}

# 2) MEDIUM pair — 30m & 6h with 5% budget → burn rate ≈ 6
resource "aws_cloudwatch_metric_alarm" "med_short" {
  alarm_name          = "${var.name_prefix}-${var.service_name}-br-med-30m"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 6
  evaluation_periods  = 1
  period              = 1800
  treat_missing_data  = "missing"
  alarm_actions       = [var.sns_topic_arn]

  metric_query { id = "e" metric { namespace = "${local.ns}/${local.svc_uc}" metric_name = "Errors"   stat = "Sum" period = 1800 } }
  metric_query { id = "r" metric { namespace = "${local.ns}/${local.svc_uc}" metric_name = "Requests" stat = "Sum" period = 1800 } }
  metric_query { id = "br" expression = "(e / r) / ${local.ebudg}" label = "burn_rate_30m" return_data = true }
}

resource "aws_cloudwatch_metric_alarm" "med_long" {
  alarm_name          = "${var.name_prefix}-${var.service_name}-br-med-6h"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 6
  evaluation_periods  = 1
  period              = 21600
  treat_missing_data  = "missing"
  alarm_actions       = [var.sns_topic_arn]

  metric_query { id = "e" metric { namespace = "${local.ns}/${local.svc_uc}" metric_name = "Errors"   stat = "Sum" period = 21600 } }
  metric_query { id = "r" metric { namespace = "${local.ns}/${local.svc_uc}" metric_name = "Requests" stat = "Sum" period = 21600 } }
  metric_query { id = "br" expression = "(e / r) / ${local.ebudg}" label = "burn_rate_6h" return_data = true }
}

resource "aws_cloudwatch_composite_alarm" "med_pair" {
  alarm_name        = "${var.name_prefix}-${var.service_name}-br-med-pair"
  alarm_description = "Multi‑window burn (30m&6h) — page / escalate"
  alarm_rule        = "ALARM(${aws_cloudwatch_metric_alarm.med_short.alarm_name}) AND ALARM(${aws_cloudwatch_metric_alarm.med_long.alarm_name})"
  alarm_actions     = [var.sns_topic_arn]
}

# 3) SLOW pair — 6h & 3d with 10% budget → burn rate ≈ 1
resource "aws_cloudwatch_metric_alarm" "slow_short" {
  alarm_name          = "${var.name_prefix}-${var.service_name}-br-slow-6h"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 1
  evaluation_periods  = 1
  period              = 21600
  treat_missing_data  = "missing"
  alarm_actions       = [var.sns_topic_arn]

  metric_query { id = "e" metric { namespace = "${local.ns}/${local.svc_uc}" metric_name = "Errors"   stat = "Sum" period = 21600 } }
  metric_query { id = "r" metric { namespace = "${local.ns}/${local.svc_uc}" metric_name = "Requests" stat = "Sum" period = 21600 } }
  metric_query { id = "br" expression = "(e / r) / ${local.ebudg}" label = "burn_rate_6h" return_data = true }
}

resource "aws_cloudwatch_metric_alarm" "slow_long" {
  alarm_name          = "${var.name_prefix}-${var.service_name}-br-slow-3d"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 1
  evaluation_periods  = 1
  period              = 259200
  treat_missing_data  = "missing"
  alarm_actions       = [var.sns_topic_arn]

  metric_query { id = "e" metric { namespace = "${local.ns}/${local.svc_uc}" metric_name = "Errors"   stat = "Sum" period = 259200 } }
  metric_query { id = "r" metric { namespace = "${local.ns}/${local.svc_uc}" metric_name = "Requests" stat = "Sum" period = 259200 } }
  metric_query { id = "br" expression = "(e / r) / ${local.ebudg}" label = "burn_rate_3d" return_data = true }
}

resource "aws_cloudwatch_composite_alarm" "slow_pair" {
  alarm_name        = "${var.name_prefix}-${var.service_name}-br-slow-pair"
  alarm_description = "Multi‑window burn (6h&3d) — ticket / daytime response"
  alarm_rule        = "ALARM(${aws_cloudwatch_metric_alarm.slow_short.alarm_name}) AND ALARM(${aws_cloudwatch_metric_alarm.slow_long.alarm_name})"
  alarm_actions     = [var.sns_topic_arn]
}

# Platform‑level composite (ANY service degraded)
resource "aws_cloudwatch_composite_alarm" "platform_degraded_any" {
  alarm_name        = "${var.name_prefix}-${var.service_name}-platform-degraded-any"
  alarm_description = "Any service fast/med/slow pair alarmed → platform degraded"
  alarm_rule        = "ALARM(${aws_cloudwatch_composite_alarm.fast_pair.alarm_name}) OR ALARM(${aws_cloudwatch_composite_alarm.med_pair.alarm_name}) OR ALARM(${aws_cloudwatch_composite_alarm.slow_pair.alarm_name})"
  alarm_actions     = [var.sns_topic_arn]
}

# Outputs
output "fast_pair_alarm_name" { value = aws_cloudwatch_composite_alarm.fast_pair.alarm_name }
output "med_pair_alarm_name"  { value = aws_cloudwatch_composite_alarm.med_pair.alarm_name }
output "slow_pair_alarm_name" { value = aws_cloudwatch_composite_alarm.slow_pair.alarm_name }
