# p95 TargetResponseTime anomaly detection alarm on ALB Target Group
data "aws_caller_identity" "current" {}

resource "aws_cloudwatch_metric_alarm" "alb_p95_latency_anom" {
  alarm_name          = "${var.name_prefix}-alb-p95-latency-anomaly"
  alarm_description   = "Anomaly detection on ALB TG p95 latency"
  comparison_operator = "GreaterThanUpperThreshold"
  evaluation_periods  = 3
  threshold_metric_id = "ad1"
  treat_missing_data  = "missing"
  alarm_actions       = [var.sns_topic_arn]

  metric_query {
    id = "m1"
    metric {
      namespace   = "AWS/ApplicationELB"
      metric_name = "TargetResponseTime"
      dimensions = {
        TargetGroup  = var.alb_target_group
        LoadBalancer = var.alb_name
      }
      period   = 60
      stat     = "p95"
      unit     = "Seconds"
    }
  }

  metric_query {
    id          = "ad1"
    expression  = "ANOMALY_DETECTION_BAND(m1, 2)"
    label       = "anomaly-band"
    return_data = true
  }
}
