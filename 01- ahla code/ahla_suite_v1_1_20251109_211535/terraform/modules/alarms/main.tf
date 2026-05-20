
resource "aws_sns_topic" "alerts" { name = "ahla-alerts" }
resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.sns_email
}

# ECS CPU/Memory alarms per service
locals { services = var.service_names }
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  for_each            = toset(local.services)
  alarm_name          = "ahla-${each.key}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 70
  dimensions = { ClusterName = var.cluster_name, ServiceName = each.value }
  alarm_actions = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "mem_high" {
  for_each            = toset(local.services)
  alarm_name          = "ahla-${each.key}-mem-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 75
  dimensions = { ClusterName = var.cluster_name, ServiceName = each.value }
  alarm_actions = [aws_sns_topic.alerts.arn]
}

# ALB 5xx
resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "ahla-alb-5xx"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  dimensions = { LoadBalancer = var.alb_arn_suffix }
  alarm_actions = [aws_sns_topic.alerts.arn]
}
