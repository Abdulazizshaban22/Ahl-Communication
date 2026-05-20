
# Replicate blue/green (canary) for all web frontends
locals {
  web_services = {
    chat     = { port=3000, path=["/chat*","/chat/*"] }
    meet     = { port=3100, path=["/meet*","/meet/*"] }
    drive    = { port=3300, path=["/drive*","/drive/*"] }
    business = { port=3400, path=["/business*","/business/*"] }
    mail     = { port=3200, path=["/mail*","/mail/*"] }
  }
}

# Target groups + services (green) and weighted rules
resource "aws_lb_target_group" "green" {
  for_each    = local.web_services
  name        = "tg-${each.key}-green"
  port        = each.value.port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
  health_check { path="/", matcher="200-499" }
}

resource "aws_ecs_service" "green" {
  for_each       = local.web_services
  name           = "${each.key}-web-green"
  cluster        = aws_ecs_cluster.this.arn
  desired_count  = 1
  launch_type    = "FARGATE"
  task_definition = module["svc_${each.key}_web"].aws_ecs_task_definition_arn
  network_configuration {
    subnets         = var.private_subnets
    security_groups = [ aws_security_group.tasks.id ]
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.green[each.key].arn
    container_name   = "${each.key}-web"
    container_port   = each.value.port
  }
  depends_on = [ module["svc_${each.key}_web"] ]
}

resource "aws_lb_listener_rule" "canary" {
  for_each    = local.web_services
  listener_arn = module.alb.listener_https_arn
  priority     = 60 + index(keys(local.web_services), each.key)
  action {
    type = "forward"
    forward {
      target_group {
        arn    = module["svc_${each.key}_web"].tg_arn
        weight = 90
      }
      target_group {
        arn    = aws_lb_target_group.green[each.key].arn
        weight = 10
      }
      stickiness { enabled=false }
    }
  }
  condition { path_pattern { values = each.value.path } }
}
