variable "name_prefix" { type = string }
variable "cf_scope_region" { type = string } # us-east-1 for CloudFront
variable "login_path" { type = string }
variable "register_path" { type = string }
variable "atp_success_codes" { type = list(number) }
variable "atp_failure_codes" { type = list(number) }
