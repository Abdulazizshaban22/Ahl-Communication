
module "iam" { source = "../iam" }

resource "aws_cloudwatch_log_group" "lg" {
  count = var.log_group_name == null ? 0 : 1
  name  = var.log_group_name
  retention_in_days = 14
}

resource "aws_lb_target_group" "blue" {
  name     = "${var.service_name}-blue"
  port     = var.port
  protocol = var.protocol
  vpc_id   = var.vpc_id
  health_check {
    path                = var.protocol == "HTTP" ? "/health" : null
    protocol            = var.protocol
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 15
    timeout             = 5
  }
}

resource "aws_lb_listener_rule" "prod_rule" {
  count = var.protocol == "HTTP" ? 1 : 0
  listener_arn = var.listener_https_arn
  action { type = "forward" target_group_arn = aws_lb_target_group.blue.arn }
  condition { path_pattern { values = ["/${var.service_name}*", "/api/${var.service_name}*", "/${var.container_name}*"] } }
  priority = 100 + (var.port % 100)
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.service_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu    = 512
  memory = 1024
  execution_role_arn       = module.iam.task_exec_role_arn
  container_definitions = jsonencode([{
    name      = var.container_name,
    image     = var.image,
    essential = true,
    portMappings = [{ containerPort = var.port, protocol = (var.protocol == "UDP" ? "udp" : "tcp") }],
    environment = [ for k,v in var.env : { name = k, value = v } ],
    secrets     = var.secrets,
    logConfiguration: var.log_group_name == null ? null : {
      logDriver: "awslogs",
      options: {
        "awslogs-group": "${var.log_group_name}",
        "awslogs-region": "${var.aws_region}",
        "awslogs-stream-prefix": "${var.service_name}"
      }
    }
  }])
}

resource "aws_ecs_service" "this" {
  name            = var.service_name
  cluster         = var.cluster_arn
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = 2
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = var.private_subnets
    assign_public_ip = var.assign_public_ip
    security_groups  = [var.sg_tasks_id]
  }
  dynamic "load_balancer" {
    for_each = var.protocol == "HTTP" ? [1] : []
    content {
      target_group_arn = aws_lb_target_group.blue.arn
      container_name   = var.container_name
      container_port   = var.port
    }
  }
  dynamic "deployment_controller" {
    for_each = var.enable_codedeploy ? [1] : []
    content { type = "CODE_DEPLOY" }
  }
}

output "tg_blue_arn" { value = aws_lb_target_group.blue.arn }
output "svc_name" { value = aws_ecs_service.this.name }
