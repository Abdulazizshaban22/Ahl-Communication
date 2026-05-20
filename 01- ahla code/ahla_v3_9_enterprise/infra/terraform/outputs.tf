output "cloudfront_web_acl_arn" {
  description = "WAFv2 Web ACL ARN to set as web_acl_id on aws_cloudfront_distribution."
  value       = aws_wafv2_web_acl.cf_global_acl.arn
}

output "regional_web_acl_arn" {
  description = "WAFv2 Regional Web ACL ARN for ALB association."
  value       = aws_wafv2_web_acl.regional_acl.arn
}