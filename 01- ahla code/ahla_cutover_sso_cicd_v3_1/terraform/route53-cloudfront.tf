# Create A/AAAA alias records to CloudFront distribution for app_domain
data "aws_cloudfront_distribution" "dist" {
  id = aws_cloudfront_distribution.this.id
}

# CloudFront hosted zone ID is a constant: Z2FDTNDATAQYW2 (per AWS docs)
locals {
  cloudfront_zone_id = "Z2FDTNDATAQYW2"
}

resource "aws_route53_record" "app_a" {
  zone_id = var.route53_zone_id
  name    = var.app_domain
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = local.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "app_aaaa" {
  zone_id = var.route53_zone_id
  name    = var.app_domain
  type    = "AAAA"
  alias {
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = local.cloudfront_zone_id
    evaluate_target_health = false
  }
}
