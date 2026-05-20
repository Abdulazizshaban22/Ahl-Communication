
variable "cluster_arn" {}
variable "service_name" {}
variable "container_name" {}
variable "image" {}
variable "port" { type = number }
variable "env"  { type = map(string) default = {} }
variable "secrets" { type = list(object({ name=string, valueFrom=string })) default = [] }
variable "sg_tasks_id" {}
variable "private_subnets" { type = list(string) }
variable "listener_https_arn" {}
variable "vpc_id" {}
variable "aws_region" {}
variable "log_group_name" { default = null }
variable "enable_codedeploy" { type = bool, default = false }
variable "assign_public_ip" { type=bool, default=false }
variable "protocol" { type=string, default="HTTP" } # for health check / load balancer type
