
# Route53 records for your domain (replace variables or set in prod.tfvars)
variable "zone_id" {}
variable "domain" {}
variable "region" { default = "me-central-1" }

# WorkMail verification TXT (SES-generated token — replace value)
resource "aws_route53_record" "workmail_verification_txt" {
  zone_id = var.zone_id
  name    = "_amazonses.${var.domain}"
  type    = "TXT"
  ttl     = 300
  records = [ "REPLACE_WITH_SES_VERIFICATION_TOKEN" ]
}

# WorkMail MX record (per-region inbound-smtp)
resource "aws_route53_record" "workmail_mx" {
  zone_id = var.zone_id
  name    = var.domain
  type    = "MX"
  ttl     = 300
  records = [ "10 inbound-smtp.${var.region}.amazonaws.com" ]
}

# SES Easy DKIM — add 3 CNAME selectors (replace <selectorX> with actual values from SES console)
resource "aws_route53_record" "ses_dkim1" {
  zone_id = var.zone_id
  name    = "selector1._domainkey.${var.domain}"
  type    = "CNAME"
  ttl     = 300
  records = [ "selector1.dkim.amazonses.com" ]
}
resource "aws_route53_record" "ses_dkim2" {
  zone_id = var.zone_id
  name    = "selector2._domainkey.${var.domain}"
  type    = "CNAME"
  ttl     = 300
  records = [ "selector2.dkim.amazonses.com" ]
}
resource "aws_route53_record" "ses_dkim3" {
  zone_id = var.zone_id
  name    = "selector3._domainkey.${var.domain}"
  type    = "CNAME"
  ttl     = 300
  records = [ "selector3.dkim.amazonses.com" ]
}

# SPF — allow Amazon SES
resource "aws_route53_record" "spf" {
  zone_id = var.zone_id
  name    = var.domain
  type    = "TXT"
  ttl     = 300
  records = [ "v=spf1 include:amazonses.com -all" ]
}

# DMARC (quarantine; adjust policy as needed)
resource "aws_route53_record" "dmarc" {
  zone_id = var.zone_id
  name    = "_dmarc.${var.domain}"
  type    = "TXT"
  ttl     = 300
  records = [ "v=DMARC1; p=quarantine; rua=mailto:dmarc@${var.domain}; ruf=mailto:dmarc@${var.domain}; fo=1" ]
}
