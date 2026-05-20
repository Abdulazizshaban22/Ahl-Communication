# Ahla v3.9 — WAF + Dashboards + CI/CD (Terraform)

## CloudFront WAF (CLOUDFRONT scope)
1) Apply this stack to create a global Web ACL with:
   - AWSManagedRulesBotControlRuleSet
   - AWSManagedRulesACFPRuleSet (Account Creation Fraud Prevention)
   - AWSManagedRulesKnownBadInputsRuleSet
   - AWSManagedRulesCommonRuleSet

2) Attach the resulting `cloudfront_web_acl_arn` to your CloudFront distribution:
   - If you use Terraform for the distribution, set:
     ```hcl
     resource "aws_cloudfront_distribution" "app" {
       # ...
       web_acl_id = module.ahla_waf.cloudfront_web_acl_arn
     }
     ```
   - If the distribution exists already, associate via console or CLI.

## Regional WAF for ALB (optional)
- Provide `var.alb_arn` to auto-associate using `aws_wafv2_web_acl_association`.

## Usage
```bash
cd infra/terraform
terraform init
terraform apply -var="region=eu-central-1" -auto-approve
```