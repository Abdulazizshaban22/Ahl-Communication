# -----------------------------
# WAFv2 Web ACL (CloudFront)
# -----------------------------
resource "aws_wafv2_web_acl" "cf_global_acl" {
  provider    = aws.us_east_1
  name        = "ahla-cf-global-acl"
  description = "Ahla global WAF for CloudFront with AWS managed rules (Bot Control, ACFP, Common)."
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "ahla-cf-global-acl"
    sampled_requests_enabled   = true
  }

  rule {
    name     = "AWS-AWSManagedRulesBotControlRuleSet"
    priority = 10
    override_action { none {} }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesBotControlRuleSet"
        vendor_name = "AWS"
        rule_action_overrides = []
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "ahla-bot-control"
      sampled_requests_enabled   = true
    }
  }

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
      metric_name                = "ahla-acfp"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
    priority = 30
    override_action { none {} }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "ahla-known-bad"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 40
    override_action { none {} }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "ahla-common"
      sampled_requests_enabled   = true
    }
  }
}

# Optional: Regional WAF for ALB (associate if alb_arn provided)
resource "aws_wafv2_web_acl" "regional_acl" {
  name        = "ahla-regional-acl"
  description = "Ahla regional WAF for ALB (optional)."
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

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

resource "aws_wafv2_web_acl_association" "alb_assoc" {
  count        = var.alb_arn == null ? 0 : 1
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.regional_acl.arn
}