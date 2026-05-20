# ========== CloudFront + WAF in front of Orchestrator ==========

# Flip ALB to internet-facing: update existing aws_lb.internal (from main.tf)
# Change:
#   internal           = false
#   subnets            = module.vpc.public_subnets
# Or create a second public ALB if you prefer.

# AWS-managed prefix list for CloudFront (origin-facing)
data "aws_prefix_list" "cloudfront_origin_ipv4" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

# Security group rule to only allow CloudFront to reach ALB (HTTP 80)
resource "aws_security_group_rule" "alb_from_cloudfront_http" {
  type              = "ingress"
  security_group_id = aws_security_group.alb.id
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  prefix_list_ids   = [data.aws_prefix_list.cloudfront_origin_ipv4.id]
  description       = "Allow HTTP from CloudFront managed prefix list"
}

# Optional: HTTPS 443 if you terminate TLS at ALB
# resource "aws_security_group_rule" "alb_from_cloudfront_https" {
#   type              = "ingress"
#   security_group_id = aws_security_group.alb.id
#   from_port         = 443
#   to_port           = 443
#   protocol          = "tcp"
#   prefix_list_ids   = [data.aws_prefix_list.cloudfront_origin_ipv4.id]
#   description       = "Allow HTTPS from CloudFront managed prefix list"
# }

# CloudFront Distribution with ALB as origin
resource "aws_cloudfront_distribution" "aif_orchestrator" {
  enabled             = true
  comment             = "${var.project} — Orchestrator public edge"
  default_root_object = ""

  origin {
    domain_name = aws_lb.internal.dns_name
    origin_id   = "aif-orchestrator-alb"

    custom_header {
      name  = "X-From-CloudFront"
      value = "true"
    }

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"   # change to 'https-only' if ALB uses TLS
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET","HEAD","OPTIONS","PUT","POST","PATCH","DELETE"]
    cached_methods   = ["GET","HEAD"]
    target_origin_id = "aif-orchestrator-alb"

    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = true
      headers      = ["Authorization", "Content-Type", "X-From-CloudFront"]
      cookies { forward = "all" }
    }

    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0
  }

  restrictions { geo_restriction { restriction_type = "none" } }
  viewer_certificate {
    cloudfront_default_certificate = true
    # or use acm_certificate_arn in us-east-1 for your custom domain
  }
}

# WAFv2 Web ACL (CloudFront scope is always us-east-1)
provider "aws" {
  alias  = "use1"
  region = "us-east-1"
}

resource "aws_wafv2_web_acl" "edge_acl" {
  provider = aws.use1
  name        = "${var.project}-edge-waf"
  scope       = "CLOUDFRONT"
  description = "Edge WAF for Ahla Orchestrator"
  default_action { allow {} }

  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 10
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }
    override_action { none {} }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "common"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWS-BotControl"
    priority = 20
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesBotControlRuleSet"
        vendor_name = "AWS"
        # inspection_level = "TARGETED" # optional
      }
    }
    override_action { none {} }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "botcontrol"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWS-AccountTakeoverPrevention"
    priority = 30
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesATPRuleSet"
        vendor_name = "AWS"
        # You must also integrate your login endpoint (SDK) / or label via app, per AWS docs.
      }
    }
    override_action { none {} }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "atp"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "edge-web-acl"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_association" "edge_acl_assoc" {
  provider     = aws.use1
  resource_arn = aws_cloudfront_distribution.aif_orchestrator.arn
  web_acl_arn  = aws_wafv2_web_acl.edge_acl.arn
}

# -------- Canary + Alarms (Apdex-style) --------

resource "aws_synthetics_canary" "orch_health" {
  name                 = "${var.project}-orch-health"
  artifact_s3_location = "s3://synthetics-${var.project}/"
  execution_role_arn   = "" # fill with IAM role for canaries
  runtime_version      = "syn-nodejs-puppeteer-7.0"
  handler              = "page.handler"
  start_canary         = true
  schedule { expression = "rate(1 minute)" }

  success_retention_period = 31
  failure_retention_period = 31

  run_config {
    timeout_in_seconds = 30
    memory_in_mb       = 960
    active_tracing     = false
    environment_variables = {
      URL = "https://${aws_cloudfront_distribution.aif_orchestrator.domain_name}/health"
      T_APDEX = "1.0"
    }
  }

  s3_bucket { bucket = "synthetics-${var.project}" }

  code {
    handler = "page.handler"
    script  = <<'EOT'
const synthetics = require('Synthetics');
const log = require('SyntheticsLogger');
const https = require('https');

const page = async function () {
  const url = process.env.URL;
  const start = Date.now();
  await synthetics.executeHttpStep('GET /health', url, { method: 'GET', timeout: 30000 });
  const dur = (Date.now() - start) / 1000.0;
  log.info(`duration=${dur}`);
};
exports.handler = async () => { return await page(); };
EOT
  }
}

# CloudWatch metric math: Apdex ~= (p_satisfied + 0.5*p_tolerating) / total
# Here, approximate using Canary's Duration metric with thresholds T and 4T.
# NOTE: This is a practical approximation; refine with custom metrics if needed.

resource "aws_cloudwatch_metric_alarm" "apdex_low" {
  alarm_name          = "${var.project}-apdex-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 5
  threshold           = 0.85
  treat_missing_data  = "breaching"

  metric_query {
    id          = "m1"
    label       = "Duration"
    return_data = false
    metric {
      metric_name = "Duration"
      namespace   = "CloudWatchSynthetics"
      period      = 60
      stat        = "Average"
      dimensions = {
        CanaryName = aws_synthetics_canary.orch_health.name
      }
    }
  }

  metric_query {
    id = "apdex"
    expression = "( IF(m1 < 1.0, 1, 0) + 0.5*IF(m1 >= 1.0 AND m1 < 4.0, 1, 0) )"
    label = "Apdex"
    return_data = true
  }
}

# Error-rate alarm from CloudFront
resource "aws_cloudwatch_metric_alarm" "cf_5xx_high" {
  alarm_name          = "${var.project}-cf-5xx-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  threshold           = 1.0
  treat_missing_data  = "notBreaching"
  metric_name         = "5xxErrorRate"
  namespace           = "AWS/CloudFront"
  statistic           = "Average"
  period              = 60
  dimensions = {
    DistributionId = aws_cloudfront_distribution.aif_orchestrator.id
    Region         = "Global"
  }
}
