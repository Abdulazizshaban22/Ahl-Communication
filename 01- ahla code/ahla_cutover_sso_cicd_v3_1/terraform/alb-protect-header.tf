# Enforce header from CloudFront to reach target groups
# Update listener rules to require both path AND http header match
resource "aws_lb_listener_rule" "protect_chat" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 21
  action { type = "forward" target_group_arn = aws_lb_target_group.tg_chat.arn }
  condition { path_pattern { values = ["/ws","/ws/*"] } }
  condition { http_header { http_header_name = "X-ALB-SECRET" values = [var.alb_header_secret] } }
}

resource "aws_lb_listener_rule" "protect_meet" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 22
  action { type = "forward" target_group_arn = aws_lb_target_group.tg_meet.arn }
  condition { path_pattern { values = ["/meet*"] } }
  condition { http_header { http_header_name = "X-ALB-SECRET" values = [var.alb_header_secret] } }
}

resource "aws_lb_listener_rule" "protect_drive" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 23
  action { type = "forward" target_group_arn = aws_lb_target_group.tg_drive.arn }
  condition { path_pattern { values = ["/drive*", "/drive/*"] } }
  condition { http_header { http_header_name = "X-ALB-SECRET" values = [var.alb_header_secret] } }
}

resource "aws_lb_listener_rule" "protect_keycloak" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 24
  action { type = "forward" target_group_arn = aws_lb_target_group.tg_keycloak.arn }
  condition { path_pattern { values = ["/auth/*"] } }
  condition { http_header { http_header_name = "X-ALB-SECRET" values = [var.alb_header_secret] } }
}

# Default action denies requests without the secret header
resource "aws_lb_listener" "https_deny_by_default" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.alb_cert_arn
  default_action {
    type = "fixed-response"
    fixed_response { content_type = "text/plain" message_body = "Forbidden" status_code = "403" }
  }
}
