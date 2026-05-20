variable "project" {}
variable "vpc_id" {}
variable "public_subnets" { type = list(string) }
variable "domain_name" {}
variable "certificate_arn" {}

resource "aws_lb" "this" {
  name = "${var.project}-alb"
  load_balancer_type = "application"
  subnets = var.public_subnets
}

resource "aws_lb_target_group" "http" {
  name = "${var.project}-tg"
  port = 80
  protocol = "HTTP"
  vpc_id = var.vpc_id
  target_type = "ip"
  health_check { path = "/health" }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port = 80
  protocol = "HTTP"
  default_action { type = "forward"; target_group_arn = aws_lb_target_group.http.arn }
}

output "alb_dns" { value = aws_lb.this.dns_name }
output "tg_http_arn" { value = aws_lb_target_group.http.arn }