
resource "aws_lb" "nlb" {
  name = "ahla-turn-nlb"
  load_balancer_type = "network"
  subnets = var.public_subnets
}

resource "aws_lb_target_group" "udp" {
  name     = "turn-udp-3478"
  port     = 3478
  protocol = "UDP"
  target_type = "ip"
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group" "tcp" {
  name     = "turn-tcp-3478"
  port     = 3478
  protocol = "TCP"
  target_type = "ip"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "udp" {
  load_balancer_arn = aws_lb.nlb.arn
  port = 3478
  protocol = "UDP"
  default_action { type="forward" target_group_arn = aws_lb_target_group.udp.arn }
}

resource "aws_lb_listener" "tcp" {
  load_balancer_arn = aws_lb.nlb.arn
  port = 3478
  protocol = "TCP"
  default_action { type="forward" target_group_arn = aws_lb_target_group.tcp.arn }
}

resource "aws_route53_record" "turn" {
  zone_id = var.route53_zone_id
  name    = "turn.${var.domain_name}"
  type    = "A"
  alias { name = aws_lb.nlb.dns_name, zone_id = aws_lb.nlb.zone_id, evaluate_target_health = false }
}

output "nlb_dns" { value = aws_lb.nlb.dns_name }
output "tg_udp_arn" { value = aws_lb_target_group.udp.arn }
output "tg_tcp_arn" { value = aws_lb_target_group.tcp.arn }
