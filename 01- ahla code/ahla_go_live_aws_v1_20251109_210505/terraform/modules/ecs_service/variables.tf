
variable "cluster_arn" {}
variable "service_name" {}
variable "container_name" {}
variable "image" {}
variable "port" { type = number }
variable "env"  { type = map(string)  default = {} }
variable "secrets" { type = list(object({ name=string, valueFrom=string })) default = [] }
variable "sg_tasks_id" {}
variable "private_subnets" { type = list(string) }

# ALB wiring
variable "alb_arn" {}
variable "listener_https_arn" {}
variable "listener_test_arn" {}
variable "vpc_id" {}

# Blue/Green toggle
variable "enable_codedeploy" { type = bool, default = false }
