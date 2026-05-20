# Application Load Balancer for HTTP/HTTPS services
resource "aws_lb" "alb" {
  name               = "${var.project}-alb"
  load_balancer_type = "application"
  subnets            = [for s in aws_subnet.public : s.id]
  security_groups    = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.alb_cert_arn
  default_action {
    type = "fixed-response"
    fixed_response { content_type = "text/plain" message_body = "Ahla ALB OK" status_code = "200" }
  }
}

# Target groups for chat and meet-signaling
resource "aws_lb_target_group" "tg_chat" {
  name        = "${var.project}-tg-chat"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.this.id
  health_check { path = "/health" matcher = "200-399" }
}

resource "aws_lb_target_group" "tg_meet" {
  name        = "${var.project}-tg-meet"
  port        = 3001
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.this.id
  health_check { path = "/health" matcher = "200-399" }
}

# Listener rules (host/path examples)
resource "aws_lb_listener_rule" "chat_rule" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 10
  action { type = "forward" target_group_arn = aws_lb_target_group.tg_chat.arn }
  condition { path_pattern { values = ["/ws","/ws/*"] } }
}

resource "aws_lb_listener_rule" "meet_rule" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 11
  action { type = "forward" target_group_arn = aws_lb_target_group.tg_meet.arn }
  condition { path_pattern { values = ["/meet*"] } }
}

# Network Load Balancer for TURN (UDP 3478 + TCP 5349)
resource "aws_lb" "nlb_turn" {
  name               = "${var.project}-nlb-turn"
  load_balancer_type = "network"
  subnets            = [for s in aws_subnet.public : s.id]
}

resource "aws_lb_target_group" "tg_turn_udp" {
  name        = "${var.project}-tg-turn-udp"
  port        = 3478
  protocol    = "UDP"
  target_type = "ip"
  vpc_id      = aws_vpc.this.id
  health_check { protocol = "TCP" port = "3478" }
}

resource "aws_lb_target_group" "tg_turn_tls" {
  name        = "${var.project}-tg-turn-tls"
  port        = 5349
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = aws_vpc.this.id
  health_check { protocol = "TCP" port = "5349" }
}

resource "aws_lb_listener" "nlb_udp_3478" {
  load_balancer_arn = aws_lb.nlb_turn.arn
  port              = 3478
  protocol          = "UDP"
  default_action { type = "forward" target_group_arn = aws_lb_target_group.tg_turn_udp.arn }
}

resource "aws_lb_listener" "nlb_tcp_5349" {
  load_balancer_arn = aws_lb.nlb_turn.arn
  port              = 5349
  protocol          = "TCP"
  default_action { type = "forward" target_group_arn = aws_lb_target_group.tg_turn_tls.arn }
}
