variable "project" { type=string }
variable "region"  { type=string  default="me-central-1" }
variable "db_username" { type=string default="ahla_user" }
variable "db_password" { type=string sensitive=true }
variable "ecr_repo_api" { type=string default="ahla/svc-api" }
variable "ecr_repo_web" { type=string default="ahla/svc-web" }
variable "canary_role_arn" { type=string default="" }
