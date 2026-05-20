
variable "vpc_id" {}
variable "public_subnets" { type = list(string) }
variable "target_sg_id" {}
variable "domain_name" {}
variable "route53_zone_id" {}
