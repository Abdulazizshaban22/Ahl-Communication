# Web ACL for CloudFront (Global)
resource "aws_wafv2_web_acl" "cf_acl" {
  provider    = aws.us_east_1
  name        = "${var.project}-cf-acl"
  scope       = "CLOUDFRONT"
  description = "Ahla global WAF — Bot Control (TARGETED) + ACFP + Common"

  default_action { allow {} }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.project}-cf-acl"
    sampled_requests_enabled   = true
  }

  # Bot Control (TARGETED inspection level)
  rule {
    name     = "AWS-AWSManagedRulesBotControlRuleSet-Targeted"
    priority = 10
    override_action { none {} }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesBotControlRuleSet"
        vendor_name = "AWS"
        managed_rule_group_configs {
          aws_managed_rules_bot_control_rule_set {
            inspection_level = "TARGETED"
          }
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.project}-botcontrol-targeted"
      sampled_requests_enabled   = true
    }
  }

  # Account Creation Fraud Prevention (ACFP) — defaults (can be tuned via labels/headers later)
  rule {
    name     = "AWS-AWSManagedRulesACFPRuleSet"
    priority = 20
    override_action { none {} }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesACFPRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.project}-acfp"
      sampled_requests_enabled   = true
    }
  }

  # Common protections
  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 30
    override_action { none {} }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.project}-common"
      sampled_requests_enabled   = true
    }
  }
}

# (If CloudFront distribution is managed in this stack, set web_acl_id on the distribution resource.)
output "cf_web_acl_arn" { value = aws_wafv2_web_acl.cf_acl.arn }
