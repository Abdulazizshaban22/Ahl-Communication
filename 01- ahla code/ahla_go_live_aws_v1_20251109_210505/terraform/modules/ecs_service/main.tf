
# Target groups
resource "aws_lb_target_group" "blue" {
  name     = "${var.service_name}-blue"
  port     = var.port
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check { path = "/health" }
}

resource "aws_lb_target_group" "green" {
  count    = var.enable_codedeploy ? 1 : 0
  name     = "${var.service_name}-green"
  port     = var.port
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check { path = "/health" }
}

# Listener rule (prod) – forward to BLUE by default
resource "aws_lb_listener_rule" "prod_rule" {
  listener_arn = var.listener_https_arn
  action { type = "forward" target_group_arn = aws_lb_target_group.blue.arn }
  condition { path_pattern { values = ["/${var.service_name}*", "/${var.container_name}*"] } }
  priority = 100 + tonumber(replace(replace(var.port, "/[^0-9]/", ""), "", ""))
}

# ECS task definition
resource "aws_ecs_task_definition" "this" {
  family                   = var.service_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu    = 512
  memory = 1024
  execution_role_arn       = module.iam.task_exec_role_arn
  container_definitions = jsonencode([
    {
      name      = var.container_name,
      image     = var.image,
      essential = true,
      portMappings = [{ containerPort = var.port, protocol = "tcp" }],
      environment = [ for k,v in var.env : { name = k, value = v } ],
      secrets     = var.secrets
    }
  ])
}

# IAM submodule usage (local reference via module block)
module "iam" {
  source = "../iam"
}

# ECS service
resource "aws_ecs_service" "this" {
  name            = var.service_name
  cluster         = var.cluster_arn
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = 2
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = var.private_subnets
    assign_public_ip = false
    security_groups = [var.sg_tasks_id]
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.blue.arn
    container_name   = var.container_name
    container_port   = var.port
  }
  dynamic "deployment_controller" {
    for_each = var.enable_codedeploy ? [1] : []
    content { type = "CODE_DEPLOY" }
  }
}

# CodeDeploy (optional)
resource "aws_codedeploy_app" "app" {
  count = var.enable_codedeploy ? 1 : 0
  name  = "${var.service_name}-cd-app"
  compute_platform = "ECS"
}

resource "aws_codedeploy_deployment_group" "dg" {
  count              = var.enable_codedeploy ? 1 : 0
  app_name           = aws_codedeploy_app.app[0].name
  deployment_group_name = "${var.service_name}-dg"
  service_role_arn   = module.iam.codedeploy_role_arn

  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    terminate_blue_instances_on_deployment_success { action = "TERMINATE", termination_wait_time_in_minutes = 1 }
    deployment_ready_option { action_on_timeout = "CONTINUE_DEPLOYMENT" }
  }

  ecs_service { cluster_name = split("/", var.cluster_arn)[length(split("/", var.cluster_arn))-1]
                service_name = var.service_name }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route { listener_arns = [var.listener_https_arn] }
      test_traffic_route { listener_arns = [var.listener_test_arn] }
      target_group { name = aws_lb_target_group.blue.name }
      target_group { name = aws_lb_target_group.green[0].name }
    }
  }
}

output "tg_blue_arn" { value = aws_lb_target_group.blue.arn }
