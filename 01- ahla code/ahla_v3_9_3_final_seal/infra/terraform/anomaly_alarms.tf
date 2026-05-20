# Example: Anomaly detection on ALB TargetResponseTime p95 and Apdex (custom metric)

# Latency (ALB p95) anomaly
resource "aws_cloudwatch_metric_alarm" "anomaly_latency_chat" {
  alarm_name          = "${var.project}-anomaly-latency-chat"
  comparison_operator = "GreaterThanUpperThreshold"
  evaluation_periods  = 10
  datapoints_to_alarm = 3
  treat_missing_data  = "missing"
  alarm_actions       = [var.sns_topic_arn]

  metric_query {
    id = "m1"
    metric {
      namespace   = "AWS/ApplicationELB"
      metric_name = "TargetResponseTime"
      period      = 60
      stat        = "p95"
      dimensions = {
        LoadBalancer = var.alb_load_balancer
        TargetGroup  = var.alb_tg_chat
      }
    }
  }

  metric_query {
    id          = "ad1"
    expression  = "ANOMALY_DETECTION_BAND(m1)"
    label       = "Latency (anomaly band)"
    return_data = True
  }
}

# Apdex anomaly (custom metric in CloudWatch)
resource "aws_cloudwatch_metric_alarm" "anomaly_apdex_chat" {
  alarm_name          = "${var.project}-anomaly-apdex-chat"
  comparison_operator = "LessThanLowerOrGreaterThanUpperThreshold"
  evaluation_periods  = 10
  datapoints_to_alarm = 3
  treat_missing_data  = "missing"
  alarm_actions       = [var.sns_topic_arn]

  metric_query {
    id = "m1"
    metric {
      namespace   = "Ahla/Chat"
      metric_name = "Apdex"
      period      = 60
      stat        = "Average"
      dimensions = {
        Service = "chat"
      }
    }
  }

  metric_query {
    id          = "ad1"
    expression  = "ANOMALY_DETECTION_BAND(m1)"
  }
}
