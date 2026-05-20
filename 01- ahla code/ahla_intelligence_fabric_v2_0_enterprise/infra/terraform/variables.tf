variable "project" { type = string }
variable "region"  { type = string  default = "me-central-1" }
variable "az_count" { type = number default = 2 }
variable "vpc_cidr" { type = string default = "10.40.0.0/16" }

# DB
variable "db_username" { type = string default = "aif_user" }
variable "db_password" { type = string sensitive = true }
variable "db_instance_class" { type = string default = "db.t4g.medium" }

# MSK
variable "msk_mode" { type = string default = "serverless-iam" } # or "provisioned-scram"
variable "msk_cluster_name" { type = string default = "aif-msk" }
variable "msk_scram_username" { type = string default = "" }
variable "msk_scram_password" { type = string default = "" sensitive = true }

# ECR
variable "ecr_repo_orchestrator" { type = string default = "aif/orchestrator" }
variable "ecr_repo_workers"      { type = string default = "aif/workers" }

# Canary
variable "canary_role_arn" { type = string default = "" }
