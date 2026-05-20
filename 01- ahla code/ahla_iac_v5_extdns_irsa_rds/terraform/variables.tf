
variable "name"            { type = string, default = "ahla" }
variable "region"          { type = string, default = "us-east-1" }
variable "domain"          { type = string, description = "Base domain (e.g., ahla.com)" }
variable "hosted_zone_id"  { type = string, description = "Route53 public hosted zone ID for domain" }
variable "acme_email"      { type = string, default = "admin@ahla.com" }

# RDS
variable "db_instance_class" { type = string, default = "db.m6i.large" }
variable "db_allocated_storage" { type = number, default = 100 }
variable "db_max_allocated_storage" { type = number, default = 500 }
variable "db_engine_version" { type = string, default = "15.5" }
variable "db_username" { type = string, default = "app_user" }
variable "db_password" { type = string, sensitive = true, default = "app_pass_change_me" }
variable "enable_rds_proxy" { type = bool, default = true }

# Mobile gateway image
variable "mobile_gateway_image_repo" { type = string, default = "ghcr.io/ahla/mobile-gateway" }
variable "mobile_gateway_image_tag"  { type = string, default = "latest" }
