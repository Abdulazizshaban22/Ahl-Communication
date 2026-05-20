output "cloudfront_web_acl_arn" {
  description = "Provide this ARN to CloudFront distribution web_acl_id"
  value       = var.cloudfront_web_acl_arn
}

output "sns_topic_arn" {
  value       = aws_sns_topic.slo_alerts.arn
  description = "SNS topic for SLO alerts"
}
