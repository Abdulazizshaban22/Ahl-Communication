resource "aws_wafv2_web_acl" "ahla_acfp" {
  name        = "ahla-acfp"
  scope       = "CLOUDFRONT"
  description = "Account Creation Fraud Prevention for signup/register"
  default_action { allow {} }
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "ahla-acfp"
    sampled_requests_enabled   = true
  }
  rule {
    name     = "AWSManagedRulesACFPRuleSet"
    priority = 10
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesACFPRuleSet"
        vendor_name = "AWS"
        managed_rule_group_configs {
          aws_managed_rules_acfp_rule_set {
            registration_page_path = "/auth/register"
            account_creation_path  = "/auth/signup"
            payload_type           = "JSON"
            username_field         = "/email"
            password_field         = "/password"
            response_inspection {
              status_code {
                success_codes = ["201"]
                failure_codes = ["400","409","422"]
              }
            }
          }
        }
      }
    }
    override_action { none {} }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "acfp"
      sampled_requests_enabled   = true
    }
  }
}
