# IMPORTANT: For CloudFront, provider must be us-east-1
provider "aws" {
  alias  = "us_east_1"
  region = var.cf_scope_region
}

resource "aws_wafv2_web_acl" "cf_acl" {
  provider    = aws.us_east_1
  name        = "${var.name_prefix}-cf-acl"
  description = "Ahla CloudFront ACL with BotControl + ACFP + ATP"
  scope       = "CLOUDFRONT"

  default_action { allow {} }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.name_prefix}-cf-acl"
    sampled_requests_enabled   = true
  }

  rule {
    name     = "BotControlTargeted"
    priority = 10
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesBotControlRuleSet"
        vendor_name = "AWS"
        managed_rule_group_configs {
          aws_managed_rules_bot_control_rule_set {
            inspection_level     = "TARGETED"
            enable_machine_learning = true
          }
        }
      }
    }
    override_action { none {} }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name_prefix}-botcontrol"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "ACFP"
    priority = 20
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesACFPRuleSet"
        vendor_name = "AWS"
        managed_rule_group_configs {
          aws_managed_rules_acfp_rule_set {
            registration_page_path = "/auth/register"
            account_creation_page_path = var.register_path
          }
        }
      }
    }
    override_action { none {} }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name_prefix}-acfp"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "ATPLogin"
    priority = 30
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesATPRuleSet"
        vendor_name = "AWS"
        managed_rule_group_configs {
          aws_managed_rules_atp_rule_set {
            login_path = var.login_path
            response_inspection {
              status_code {
                success_codes = var.atp_success_codes
                failure_codes = var.atp_failure_codes
              }
            }
          }
        }
      }
    }
    override_action { none {} }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name_prefix}-atp"
      sampled_requests_enabled   = true
    }
  }
}

output "web_acl_name" { value = aws_wafv2_web_acl.cf_acl.name }
output "web_acl_arn"  { value = aws_wafv2_web_acl.cf_acl.arn }
