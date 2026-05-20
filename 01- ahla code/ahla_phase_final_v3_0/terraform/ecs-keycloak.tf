resource "aws_ecs_task_definition" "keycloak" {
  family                   = "${var.project}-keycloak"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.keycloak_cpu
  memory                   = var.keycloak_mem
  execution_role_arn       = aws_iam_role.task_exec.arn
  container_definitions = jsonencode([{
    name      = "keycloak"
    image     = var.image_keycloak
    essential = true
    portMappings = [{ containerPort = 8080, protocol = "tcp" }]
    environment = [
      { "name":"KEYCLOAK_ADMIN", "value": var.keycloak_admin_user },
      { "name":"KEYCLOAK_ADMIN_PASSWORD", "value": var.keycloak_admin_pass }
    ]
    healthCheck = {
      command: ["CMD-SHELL","curl -f http://localhost:8080/realms/master/.well-known/openid-configuration || exit 1"],
      interval: 30, timeout: 5, retries: 5, startPeriod: 30
    }
    logConfiguration = {
      logDriver = "awslogs",
      options = {
        awslogs-group: "/ecs/${var.project}/keycloak",
        awslogs-region: var.aws_region,
        awslogs-stream-prefix: "ecs"
      }
    }
  }])
}

resource "aws_lb_target_group" "tg_keycloak" {
  name        = "${var.project}-tg-auth"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.this.id
  health_check { path = "/realms/master/.well-known/openid-configuration" matcher = "200-399" }
}

resource "aws_ecs_service" "keycloak" {
  name            = "${var.project}-keycloak"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.keycloak.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = [for s in aws_subnet.private : s.id]
    security_groups = [aws_security_group.tasks.id]
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.tg_keycloak.arn
    container_name   = "keycloak"
    container_port   = 8080
  }
}

# ALB listener rule to route /auth/* to keycloak
resource "aws_lb_listener_rule" "keycloak_rule" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 15
  action { type = "forward" target_group_arn = aws_lb_target_group.tg_keycloak.arn }
  condition { path_pattern { values = ["/auth/*"] } }
}
