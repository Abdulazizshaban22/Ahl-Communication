variable "project" { type = string }
variable "region"  { type = string  default = "me-central-1" }
variable "vpc_cidr" { type = string default = "10.20.0.0/16" }
variable "az_count" { type = number default = 2 }

variable "db_username" { type = string default = "aif_user" }
variable "db_password" { type = string sensitive = true }
variable "db_instance_class" { type = string default = "db.t4g.medium" }

variable "msk_cluster_name" { type = string default = "aif-msk" }

variable "ecr_repo_orchestrator" { type = string default = "aif/orchestrator" }
variable "ecr_repo_workers"      { type = string default = "aif/workers" }

variable "open_search_log_sink_arn" { type = string default = "" } # optional
