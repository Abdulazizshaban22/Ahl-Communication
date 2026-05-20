variable "project" { type = string }
variable "region"  { type = string  default = "us-east-1" }
variable "vpc_cidr"{ type = string  default = "10.0.0.0/16" }
variable "azs"     { type = list(string) default = ["us-east-1a","us-east-1b","us-east-1c"] }
variable "eks_version" { type = string default = "1.30" }
variable "db_username" { type = string default = "ahladb" }
variable "db_password" { type = string }
variable "db_engine_version" { type = string default = "16.3" } # Aurora PostgreSQL
variable "domain" { type = string }
