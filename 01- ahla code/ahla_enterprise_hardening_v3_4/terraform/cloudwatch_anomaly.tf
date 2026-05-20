# p95 TargetResponseTime anomaly alarm (ALB)
resource "aws_cloudwatch_metric_alarm" "alb_latency_anomaly" {
  alarm_name          = "${var.project}-alb-latency-anomaly"
  alarm_description   = "Anomaly detection on ALB TargetResponseTime p95"
  comparison_operator = "LessThanLowerOrGreaterThanUpperThreshold"
  evaluation_periods  = 3
  threshold_metric_id = "ad1"
  alarm_actions       = [var.anomaly_alarm_sns_arn]
  ok_actions          = [var.anomaly_alarm_sns_arn]

  metric_query {
    id = "m1"
    metric {
      namespace   = "AWS/ApplicationELB"
      metric_name = "TargetResponseTime"
      period      = var.anomaly_period
      stat        = "p95"
      dimensions  = { LoadBalancer = var.alb_load_balancer_dimension }
    }
  }

  metric_query {
    id = "ad1"
    expression = "ANOMALY_DETECTION_BAND(m1, ${var.anomaly_band_width})"
  }
}

# 5xx error rate anomaly alarm (ALB)
resource "aws_cloudwatch_metric_alarm" "alb_5xx_anomaly" {
  alarm_name          = "${var.project}-alb-5xx-anomaly"
  alarm_description   = "Anomaly detection on ALB 5xx count"
  comparison_operator = "LessThanLowerOrGreaterThanUpperThreshold"
  evaluation_periods  = 3
  threshold_metric_id = "ad2"
  alarm_actions       = [var.anomaly_alarm_sns_arn]
  ok_actions          = [var.anomaly_alarm_sns_arn]

  metric_query {
    id = "m2"
    metric {
      namespace   = "AWS/ApplicationELB"
      metric_name = "HTTPCode_ELB_5XX_Count"
      period      = var.anomaly_period
      stat        = "Sum"
      dimensions  = { LoadBalancer = var.alb_load_balancer_dimension }
    }
  }

  metric_query {
    id = "ad2"
    expression = "ANOMALY_DETECTION_BAND(m2, ${var.anomaly_band_width})"
  }
}
