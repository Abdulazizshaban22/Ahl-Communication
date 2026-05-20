
variable "name" { type = string, default = "ahla" }
variable "region" { type = string, default = "us-east-1" }
variable "domain" { type = string, description = "Base domain e.g. ahla.com" }
variable "acme_email" { type = string, default = "admin@ahla.com" }
variable "mobile_gateway_image_repo" { type = string, default = "ghcr.io/ahla/mobile-gateway" }
variable "mobile_gateway_image_tag" { type = string, default = "latest" }
