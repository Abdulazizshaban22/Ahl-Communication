
variable "aws_region" {}
variable "cluster_arn" {}
variable "service_name" {}
variable "container_name" {}
variable "image" {}
variable "port" { default = 80 }
variable "env" { type = map(string), default = {} }
variable "secrets" {
  type = list(object({ name=string, valueFrom=string }))
  default = []
}
variable "log_group_name" {}
variable "sg_tasks_id" {}
variable "private_subnets" { type = list(string) }
variable "listener_https_arn" {}
variable "vpc_id" {}
variable "path_pattern" { default = "/*" }

resource "aws_cloudwatch_log_group" "this" {
  name              = var.log_group_name
  retention_in_days = 14
}

resource "aws_iam_role" "task_exec" {
  name = "ahla-${var.service_name}-exec"
  assume_role_policy = jsonencode({
    Version="2012-10-17", Statement=[{Effect="Allow", Principal={Service="ecs-tasks.amazonaws.com"}, Action="sts:AssumeRole"}]
  })
}

resource "aws_iam_role_policy_attachment" "exec_policy" {
  role       = aws_iam_role.task_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "this" {
  family                   = "ahla-${var.service_name}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.task_exec.arn
  container_definitions = jsonencode([
    {
      name  = var.container_name
      image = var.image
      essential = true
      portMappings = [{ containerPort = var.port, protocol="tcp" }]
      environment = [ for k,v in var.env : { name=k, value=v } ]
      secrets     = [ for s in var.secrets : { name=s.name, valueFrom=s.valueFrom } ]
      logConfiguration = {
        logDriver = "awslogs"
        options = { awslogs-region=var.aws_region, awslogs-group=var.log_group_name, awslogs-stream-prefix=var.service_name }
      }
    }
  ])
}

resource "aws_lb_target_group" "this" {
  name        = "tg-${var.service_name}"
  port        = var.port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
  health_check { path="/health" matcher="200-499" }
}

resource "aws_lb_listener_rule" "path" {
  listener_arn = var.listener_https_arn
  priority     = 200 + floor(rand()*400) # keep unique-ish
  action { type="forward" target_group_arn = aws_lb_target_group.this.arn }
  condition { path_pattern { values = [var.path_pattern] } }
  lifecycle { ignore_changes=[priority] }
}

resource "aws_ecs_service" "this" {
  name            = var.service_name
  cluster         = var.cluster_arn
  desired_count   = 2
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.this.arn
  network_configuration {
    subnets         = var.private_subnets
    security_groups = [ var.sg_tasks_id ]
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = var.container_name
    container_port   = var.port
  }
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
}

output "svc_name" { value = aws_ecs_service.this.name }
output "tg_arn"   { value = aws_lb_target_group.this.arn }
