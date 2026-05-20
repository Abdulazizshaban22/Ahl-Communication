variable "project"          { type = string  default = "ahla" }
variable "aws_region"       { type = string  default = "me-central-1" }
variable "domain_root"      { type = string  description = "Root domain, e.g., ahla.example.com" }
variable "alb_cert_arn"     { type = string  description = "ACM ARN for ALB https" }
variable "turn_cert_arn"    { type = string  description = "ACM ARN for TURN TLS (optional)" default = "" }
variable "vpc_cidr"         { type = string  default = "10.30.0.0/16" }
variable "public_subnets"   { type = list(string) default = ["10.30.1.0/24", "10.30.2.0/24"] }
variable "private_subnets"  { type = list(string) default = ["10.30.11.0/24","10.30.12.0/24"] }

# Container images
variable "image_chat"            { type = string }
variable "image_meet_signaling"  { type = string }
variable "image_coturn"          { type = string }

# Scaling
variable "chat_desired" { type = number default = 2 }
variable "chat_min"     { type = number default = 2 }
variable "chat_max"     { type = number default = 8 }
