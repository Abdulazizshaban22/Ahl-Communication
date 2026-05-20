variable "region" {
  description = "AWS region for regional resources (ALB/ECS/etc.)."
  type        = string
  default     = "eu-central-1"
}

variable "cloudfront_distribution_id" {
  description = "Existing CloudFront distribution ID to attach WAF to (optional if you manage distribution elsewhere)."
  type        = string
  default     = null
}

variable "cloudfront_distribution_web_acl_attach" {
  description = "Whether to output WAF ARN for CloudFront web_acl_id binding."
  type        = bool
  default     = true
}

variable "alb_arn" {
  description = "Optional ALB ARN to associate WAF (regional) with."
  type        = string
  default     = null
}