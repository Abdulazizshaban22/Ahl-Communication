variable "region" {
  description = "AWS region for regional resources (ALB/ECS/etc.)."
  type        = string
  default     = "eu-central-1"
}

variable "cloudfront_distribution_id" {
  description = "Existing CloudFront distribution ID (if managed outside)."
  type        = string
  default     = null
}

variable "cloudfront_web_acl_arn" {
  description = "WAFv2 Web ACL ARN (CLOUDFRONT scope) to attach to CloudFront distribution."
  type        = string
}

variable "alb_arn" {
  description = "ALB ARN to associate Regional WAF with (optional)."
  type        = string
  default     = null
}

variable "slo_target" {
  description = "SLO target percentage (e.g., 99.9)."
  type        = number
  default     = 99.9
}

variable "alb_load_balancer" {
  description = "ALB dimension value (name) for CloudWatch metrics, e.g., app/ahla-alb/123..."
  type        = string
}

variable "alb_target_group" {
  description = "TargetGroup dimension value (name), e.g., targetgroup/ahla-chat/456..."
  type        = string
}

variable "sns_email" {
  description = "Email to subscribe for SLO alerts (SNS)."
  type        = string
  default     = null
}
