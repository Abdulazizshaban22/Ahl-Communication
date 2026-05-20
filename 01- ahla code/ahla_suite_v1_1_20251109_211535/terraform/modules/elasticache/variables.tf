
variable "vpc_id" {}
variable "private_subnets" { type = list(string) }
variable "allowed_sg_id" {}
variable "engine_version" { default = "7.0" }
variable "node_type" { default = "cache.t4g.micro" }
variable "name" { default = "ahla-redis" }
