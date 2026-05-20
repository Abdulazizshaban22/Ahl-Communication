# CloudFront WAF with Bot Control + Common/BadInputs
resource "aws_wafv2_web_acl" "cf_waf_adv" {
  name        = "${var.project}-cf-waf-adv"
  description = "Ahla — CloudFront WAF (Bot Control + Common + BadInputs)"
  scope       = "CLOUDFRONT"

  default_action { allow {} }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.project}-cf-waf-adv"
    sampled_requests_enabled   = true
  }

  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 1
    override_action { none {} }
    statement { managed_rule_group_statement { vendor_name = "AWS" name = "AWSManagedRulesCommonRuleSet" } }
    visibility_config { cloudwatch_metrics_enabled = true metric_name = "${var.project}-cf-common" sampled_requests_enabled = true }
  }

  rule {
    name     = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
    priority = 2
    override_action { none {} }
    statement { managed_rule_group_statement { vendor_name = "AWS" name = "AWSManagedRulesKnownBadInputsRuleSet" } }
    visibility_config { cloudwatch_metrics_enabled = true metric_name = "${var.project}-cf-badinputs" sampled_requests_enabled = true }
  }

  rule {
    name     = "AWS-AWSManagedRulesBotControlRuleSet"
    priority = 3
    override_action { none {} }
    statement { managed_rule_group_statement { vendor_name = "AWS" name = "AWSManagedRulesBotControlRuleSet" } }
    visibility_config { cloudwatch_metrics_enabled = true metric_name = "${var.project}-cf-bot" sampled_requests_enabled = true }
  }

  # Optionally rate-limit
  rule {
    name     = "RateLimit-IP"
    priority = 10
    action { block {} }
    statement { rate_based_statement { limit = 2000 aggregate_key_type = "IP" } }
    visibility_config { cloudwatch_metrics_enabled = true metric_name = "${var.project}-cf-rate" sampled_requests_enabled = true }
  }
}

resource "aws_wafv2_web_acl_association" "cf_assoc_adv" {
  resource_arn = var.cloudfront_distribution_arn
  web_acl_arn  = aws_wafv2_web_acl.cf_waf_adv.arn
}

# ALB WAF with ATP (Account Takeover Prevention) + Common
resource "aws_wafv2_web_acl" "alb_waf_atp" {
  name        = "${var.project}-alb-waf-atp"
  description = "Ahla — ALB WAF (ATP + Common)"
  scope       = "REGIONAL"

  default_action { allow {} }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.project}-alb-waf-atp"
    sampled_requests_enabled   = true
  }

  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 1
    override_action { none {} }
    statement { managed_rule_group_statement { vendor_name = "AWS" name = "AWSManagedRulesCommonRuleSet" } }
    visibility_config { cloudwatch_metrics_enabled = true metric_name = "${var.project}-alb-common" sampled_requests_enabled = true }
  }

  # Account Takeover Prevention for login endpoints
  dynamic "rule" {
    for_each = var.login_paths
    content {
      name     = "AWS-AWSManagedRulesATPRuleSet-${replace(rule.value, "/", "_")}"
      priority = 20 + index(var.login_paths, rule.value)
      override_action { none {} }
      statement {
        rate_based_statement {
          limit = 5000
          aggregate_key_type = "IP"
          scope_down_statement {
            byte_match_statement {
              field_to_match { uri_path {} }
              positional_constraint = "STARTS_WITH"
              search_string         = rule.value
              text_transformation { priority = 0 type = "NONE" }
            }
          }
        }
      }
      visibility_config { cloudwatch_metrics_enabled = true metric_name = "${var.project}-alb-atp-${replace(rule.value, "/", "_")}" sampled_requests_enabled = true }
    }
  }
}

resource "aws_wafv2_web_acl_association" "alb_assoc_atp" {
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.alb_waf_atp.arn
}
