data "aws_lb" "alb_ref" { arn = aws_lb.alb.arn }

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "${var.project}-alb-oac"
  origin_access_control_origin_type = "custom"
  signing_behavior                  = "no-signing"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.project} distribution"
  aliases             = var.cloudfront_alt_names

  origins {
    domain_name = data.aws_lb.alb_ref.dns_name
    origin_id   = "alb-origin"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
    custom_header {
      name  = "X-ALB-SECRET"
      value = "set-a-random-secret-here"
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET","HEAD","OPTIONS","PUT","POST","PATCH","DELETE"]
    cached_methods   = ["GET","HEAD","OPTIONS"]
    target_origin_id = "alb-origin"
    viewer_protocol_policy = "redirect-to-https"
    compress = true
    forwarded_values {
      headers = ["*"]
      query_string = true
      cookies { forward = "all" }
    }
  }

  price_class = "PriceClass_All"

  restrictions { geo_restriction { restriction_type = "none" } }

  viewer_certificate {
    acm_certificate_arn = var.cloudfront_cert_arn_us_east_1
    ssl_support_method  = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

output "cloudfront_domain" { value = aws_cloudfront_distribution.this.domain_name }
