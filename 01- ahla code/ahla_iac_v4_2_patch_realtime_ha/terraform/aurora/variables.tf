
variable "name"     { type = string, default = "ahla" }
variable "region"   { type = string, default = "us-east-1" }
variable "vpc_id"   { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "ingress_cidrs"      { type = list(string), default = ["10.0.0.0/8"] }
variable "engine_version" { type = string, default = "15.4" }
variable "instance_class" { type = string, default = "db.r6g.large" }
variable "db_username" { type = string, default = "app_user" }
variable "db_password" { type = string, sensitive = true }
