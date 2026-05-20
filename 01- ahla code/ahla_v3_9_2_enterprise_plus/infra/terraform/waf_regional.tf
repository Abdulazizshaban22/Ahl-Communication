resource "aws_wafv2_web_acl" "alb_acl" {
  name        = "${var.project}-alb-acl"
  scope       = "REGIONAL"
  description = "Ahla regional WAF for ALB"

  default_action { allow {} }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.project}-alb-acl"
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
      metric_name                = "${var.project}-alb-common"
      sampled_requests_enabled   = true
    }
  }
}

resource "aws_wafv2_web_acl_association" "alb_assoc" {
  count        = var.alb_arn == null ? 0 : 1
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.alb_acl.arn
}

output "alb_web_acl_arn" { value = aws_wafv2_web_acl.alb_acl.arn }
