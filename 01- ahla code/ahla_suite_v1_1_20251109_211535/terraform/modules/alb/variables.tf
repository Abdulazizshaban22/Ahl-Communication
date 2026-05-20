
variable "vpc_id" {}
variable "public_subnets" { type = list(string) }
variable "certificate_arn" {}
variable "domain_name" {}
variable "route53_zone_id" {}
