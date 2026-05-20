variable "project" { type = string }
variable "region"  { type = string }
variable "vpc_id"  { type = string }
variable "private_subnets" { type = list(string) }
variable "public_subnets"  { type = list(string) }

# ACM for CloudFront (must be in us-east-1)
variable "acm_cert_arn" { type = string }

# Domain
variable "domain_name" { type = string }
variable "hosted_zone_id" { type = string }

# Container images
variable "image_gateway" { type = string }
variable "image_next"    { type = string }

# MSK
variable "msk_cluster_name" { type = string }
