# -----------------------------
# CloudFront association via web_acl_id (must be set on distribution resource)
# If your CloudFront distribution is managed elsewhere, use the console/API to set web_acl_id.
# -----------------------------

# Optional helper: data source to fetch distribution (by id) if you want to update via Terraform.
# (Requires you to also manage the distribution resource to set web_acl_id explicitly.)

# -----------------------------
# Regional WAF association with ALB (if provided)
# -----------------------------
resource "aws_wafv2_web_acl_association" "alb_assoc" {
  count        = var.alb_arn == null ? 0 : 1
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.regional_acl.arn
}

# Minimal regional ACL (Common rules only) to attach to ALB if needed.
resource "aws_wafv2_web_acl" "regional_acl" {
  name        = "ahla-regional-acl"
  description = "Ahla regional WAF for ALB"
  scope       = "REGIONAL"

  default_action { allow {} }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "ahla-regional-acl"
    sampled_requests_enabled   = true
  }

  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 10
    override_action { none {} }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "ahla-regional-common"
      sampled_requests_enabled   = true
    }
  }
}
