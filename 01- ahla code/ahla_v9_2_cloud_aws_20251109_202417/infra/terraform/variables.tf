variable "project" { type = string }
variable "region"  { type = string  default = "me-central-1" }
variable "domain_name" { type = string }
variable "certificate_arn" { type = string }
variable "container_image_tag" { type = string default = "v9.2" }
variable "vpc_cidr" { type = string default = "10.42.0.0/16" }
variable "public_subnets" { type = list(string) default = ["10.42.1.0/24","10.42.2.0/24"] }
variable "private_subnets" { type = list(string) default = ["10.42.11.0/24","10.42.12.0/24"] }