
variable "vpc_id" {}
variable "public_subnets" { type = list(string) }
variable "certificate_arn" {}
variable "domain_name" {}
variable "route53_zone_id" {}

resource "aws_security_group" "alb" {
  name   = "ahla-alb-sg"
  vpc_id = var.vpc_id
  ingress { from_port=80,  to_port=80,  protocol="tcp", cidr_blocks=["0.0.0.0/0"] }
  ingress { from_port=443, to_port=443, protocol="tcp", cidr_blocks=["0.0.0.0/0"] }
  egress  { from_port=0, to_port=0, protocol="-1", cidr_blocks=["0.0.0.0/0"] }
}

resource "aws_lb" "this" {
  name               = "ahla-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnets
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port = 80
  protocol = "HTTP"
  default_action { type="redirect" redirect { port="443" protocol="HTTPS" status_code="HTTP_301" } }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port = 443
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn = var.certificate_arn
  default_action { type="fixed-response" fixed_response { content_type="text/plain" status_code="200" message_body="Ahla ALB" } }
}

resource "aws_route53_record" "alb" {
  zone_id = var.route53_zone_id
  name    = var.domain_name
  type    = "A"
  alias {
    name                   = aws_lb.this.dns_name
    zone_id                = aws_lb.this.zone_id
    evaluate_target_health = true
  }
}

output "listener_https_arn" { value = aws_lb_listener.https.arn }
output "alb_dns_name" { value = aws_lb.this.dns_name }
output "alb_arn_suffix" { value = aws_lb.this.arn_suffix }
output "sg_alb_id" { value = aws_security_group.alb.id }
