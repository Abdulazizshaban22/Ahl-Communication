
# Canary-forward example for chat-web: two target groups and weighted rule.
resource "aws_lb_target_group" "chat_web_green" {
  name        = "tg-chat-web-green"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
  health_check { path="/", matcher="200-499" }
}

# Optional duplicate service for green (same task definition)
resource "aws_ecs_service" "chat_web_green" {
  name            = "chat-web-green"
  cluster         = aws_ecs_cluster.this.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  task_definition = module.svc_chat_web.aws_ecs_task_definition_arn != null ? replace(module.svc_chat_web.aws_ecs_task_definition_arn, ":1", ":1") : null
  network_configuration {
    subnets         = var.private_subnets
    security_groups = [ aws_security_group.tasks.id ]
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.chat_web_green.arn
    container_name   = "chat-web"
    container_port   = 3000
  }
  depends_on = [ module.svc_chat_web ]
}

resource "aws_lb_listener_rule" "chat_web_canary" {
  listener_arn = module.alb.listener_https_arn
  priority     = 50
  action {
    type = "forward"
    forward {
      target_group {
        arn    = module.svc_chat_web.tg_arn
        weight = 90
      }
      target_group {
        arn    = aws_lb_target_group.chat_web_green.arn
        weight = 10
      }
      stickiness { enabled=false }
    }
  }
  condition { path_pattern { values=["/chat*","/chat/*"] } }
}
