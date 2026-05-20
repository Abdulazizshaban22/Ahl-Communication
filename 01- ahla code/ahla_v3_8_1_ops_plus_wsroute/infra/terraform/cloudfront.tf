resource "aws_cloudfront_distribution" "this" {
  enabled = true
  is_ipv6_enabled = true
  aliases = [var.domain_name]
  origins {
    domain_name = aws_lb.alb.dns_name
    origin_id   = "alb-origin"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }
  default_cache_behavior {
    allowed_methods  = ["GET","HEAD","OPTIONS"]
    cached_methods   = ["GET","HEAD"]
    target_origin_id = "alb-origin"
    viewer_protocol_policy = "redirect-to-https"
    compress = true
    forwarded_values {
      query_string = true
      headers = ["Accept","Accept-Encoding","Authorization","CloudFront-Viewer-Country"]
    }
  }
  price_class = "PriceClass_200"
  viewer_certificate {
    acm_certificate_arn = var.acm_cert_arn
    ssl_support_method  = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}
resource "aws_route53_record" "cf" {
  zone_id = var.hosted_zone_id
  name    = var.domain_name
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
    evaluate_target_health = false
  }
}
output "cloudfront_domain" { value = aws_cloudfront_distribution.this.domain_name }
