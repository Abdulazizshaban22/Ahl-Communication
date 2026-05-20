
# Set green=100, blue=0 for all web services
resource "aws_lb_listener_rule" "canary" {
  for_each     = local.web_services
  listener_arn = module.alb.listener_https_arn
  priority     = 60 + index(keys(local.web_services), each.key)
  action {
    type = "forward"
    forward {
      target_group { arn = module["svc_${each.key}_web"].tg_arn, weight = 0 }
      target_group { arn = aws_lb_target_group.green[each.key].arn, weight = 100 }
      stickiness { enabled=false }
    }
  }
  condition { path_pattern { values = each.value.path } }
}
