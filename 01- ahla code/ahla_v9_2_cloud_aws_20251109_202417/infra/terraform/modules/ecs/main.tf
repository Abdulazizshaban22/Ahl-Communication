variable "project" {}
variable "cluster_name" {}
variable "vpc_id" {}
variable "private_subnets" { type=list(string) }
variable "target_group_arn" {}
variable "execution_role_arn" {}
variable "task_role_arn" {}
variable "images" { type = map(string) }

resource "aws_ecs_cluster" "this" { name = var.cluster_name }

resource "aws_security_group" "svc" {
  name   = "${var.project}-svc-sg"
  vpc_id = var.vpc_id
  ingress { from_port=80 to_port=80 protocol="tcp" cidr_blocks=["0.0.0.0/0"] }
  egress  { from_port=0  to_port=0  protocol="-1" cidr_blocks=["0.0.0.0/0"] }
}

resource "aws_ecs_task_definition" "reverse_proxy" {
  family                   = "${var.project}-reverse-proxy"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu    = "512"
  memory = "1024"
  execution_role_arn = var.execution_role_arn
  task_role_arn      = var.task_role_arn
  container_definitions = jsonencode([
    {
      name  = "reverse-proxy"
      image = var.images["reverse-proxy"]
      essential = true
      portMappings = [{ containerPort = 80, hostPort = 80 }]
      environment = []
      logConfiguration = {
        logDriver = "awslogs",
        options = { awslogs-region = "me-central-1", awslogs-group = "/ecs/${var.project}-reverse-proxy", awslogs-stream-prefix = "ecs" }
      }
    }
  ])
}

resource "aws_cloudwatch_log_group" "rp" { name = "/ecs/${var.project}-reverse-proxy"; retention_in_days = 14 }

resource "aws_ecs_service" "reverse_proxy" {
  name            = "${var.project}-reverse-proxy"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.reverse_proxy.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    assign_public_ip = true
    subnets         = var.private_subnets
    security_groups = [aws_security_group.svc.id]
  }
  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "reverse-proxy"
    container_port   = 80
  }
}
output "cluster_name" { value = aws_ecs_cluster.this.name }