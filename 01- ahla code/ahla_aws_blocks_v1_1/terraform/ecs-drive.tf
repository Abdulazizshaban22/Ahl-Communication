resource "aws_ecs_task_definition" "drive" {
  family                   = "${var.project}-drive"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.task_exec.arn
  task_role_arn            = aws_iam_role.drive_task_role.arn

  container_definitions = jsonencode([{
    name      = "drive-api"
    image     = var.image_drive
    essential = true
    portMappings = [{ containerPort = 3002, protocol = "tcp" }]
    environment = [
      { name = "AWS_REGION", value = var.aws_region },
      { name = "S3_BUCKET",  value = var.s3_bucket }
    ]
    healthCheck = {
      command     = ["CMD-SHELL","curl -f http://localhost:3002/health || exit 1"]
      interval    = 30
      timeout     = 5
      retries     = 3
      startPeriod = 10
    }
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/${var.project}/drive"
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}

resource "aws_ecs_service" "drive" {
  name            = "${var.project}-drive"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.drive.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [for s in aws_subnet.private : s.id]
    security_groups = [aws_security_group.tasks.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg_drive.arn
    container_name   = "drive-api"
    container_port   = 3002
  }
}
