terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.60" }
  }
}

provider "aws" {
  region = var.region
}

# ---------- MSK Serverless with IAM ----------
resource "aws_msk_serverless_cluster" "ahla" {
  cluster_name = "ahla-msk"
  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [aws_security_group.msk.id]
  }
  client_authentication {
    sasl {
      iam {
        enabled = true
      }
    }
  }
}

resource "aws_security_group" "msk" {
  name        = "ahla-msk-sg"
  description = "MSK access"
  vpc_id      = var.vpc_id
  ingress { from_port=9098; to_port=9098; protocol="tcp"; cidr_blocks = var.vpc_cidrs }
  egress  { from_port=0; to_port=0; protocol="-1"; cidr_blocks = ["0.0.0.0/0"] }
}

# ---------- OpenSearch ----------
resource "aws_opensearch_domain" "ahla" {
  domain_name           = "ahla-observability"
  engine_version        = "OpenSearch_2.13"
  cluster_config { instance_type="t3.small.search" instance_count=1 }
  ebs_options { ebs_enabled = true volume_size = 20 volume_type="gp3" }
  encrypt_at_rest { enabled = true }
  node_to_node_encryption { enabled = true }
  domain_endpoint_options { enforce_https = true tls_security_policy="Policy-Min-TLS-1-2-2019-07" }
  access_policies = data.aws_iam_policy_document.os_access.json
}

data "aws_iam_policy_document" "os_access" {
  statement {
    actions = ["es:*"]
    principals { type="AWS" identifiers = [var.admin_role_arn] }
    resources = ["arn:aws:es:${var.region}:${var.account_id}:domain/ahla-observability/*"]
  }
}

# ---------- OpenSearch Ingestion (OSI) pipeline with GeoIP ----------
resource "aws_osis_pipeline" "logs" {
  pipeline_name = "cw-to-opensearch-geoip"
  min_units     = 1
  max_units     = 4
  log_publishing_options {
    is_logging_enabled = true
    cloudwatch_log_destination {
      log_group = aws_cloudwatch_log_group.osis.name
    }
  }
  pipeline_configuration_body = <<-YAML
    version: "2"
    log-pipeline:
      source:
        cloudwatch:
          log_group_names: ${jsonencode(var.cw_log_groups)}
          region: ${var.region}
      processor:
        - geoip:
            field: "ip"
            target_field: "ip_geo"
      sink:
        - opensearch:
            hosts: ["${aws_opensearch_domain.ahla.endpoint}"]
            index: "ahla-logs-%{service}-%{date}"
  YAML
}

resource "aws_cloudwatch_log_group" "osis" {
  name              = "/aws/osis/pipeline"
  retention_in_days = 30
}

# ---------- ECS (Fargate) for Emotion/Talk/AI/Analyze ----------
# (Placeholders for services; wire images from ECR in prod)
# ... (task definitions + services) ...

# ---------- CloudFront + WAF with Bot Control + ATP ----------
resource "aws_cloudfront_distribution" "cdn" {
  enabled = true
  origin {
    domain_name = var.alb_dns_name
    origin_id   = "alb-origin"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }
  default_cache_behavior {
    target_origin_id = "alb-origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods  = ["GET","HEAD","OPTIONS","PUT","POST","PATCH","DELETE"]
    cached_methods   = ["GET","HEAD"]
  }
  viewer_certificate {
    acm_certificate_arn = var.acm_cert_arn
    ssl_support_method  = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
  web_acl_id = aws_wafv2_web_acl.ahla.arn
}

resource "aws_wafv2_web_acl" "ahla" {
  name        = "ahla-waf"
  scope       = "CLOUDFRONT"
  description = "WAF with BotControl + ATP"
  default_action { allow {} }
  visibility_config { cloudwatch_metrics_enabled=true metric_name="ahla-waf" sampled_requests_enabled=true }

  rule {
    name     = "AWS-AWSManagedRulesBotControlRuleSet"
    priority = 1
    override_action { none {} }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesBotControlRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config { cloudwatch_metrics_enabled=true metric_name="bot" sampled_requests_enabled=true }
  }

  rule {
    name     = "AWS-AWSManagedRulesATPRuleSet"
    priority = 2
    override_action { none {} }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesATPRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config { cloudwatch_metrics_enabled=true metric_name="atp" sampled_requests_enabled=true }
  }
}

# ---------- Variables ----------
variable "region" { type=string }
variable "account_id" { type=string }
variable "vpc_id" { type=string }
variable "vpc_cidrs" { type=list(string) }
variable "private_subnet_ids" { type=list(string) }
variable "admin_role_arn" { type=string }
variable "cw_log_groups" { type=list(string) }
variable "alb_dns_name" { type=string }
variable "acm_cert_arn" { type=string }
