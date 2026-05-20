resource "aws_ecs_task_definition" "audit" {
  family                   = "${var.project}-audit"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.task_exec.arn

  container_definitions = jsonencode([{
    name      = "audit-api"
    image     = "public.ecr.aws/docker/library/node:20-alpine" # replace with your built image
    essential = true
    portMappings = [{ containerPort = 3010, protocol = "tcp" }]
    command   = ["node","app.js"]
    environment = [
      { name = "AWS_REGION", value = var.aws_region },
      { name = "FIREHOSE_STREAM", value = aws_kinesis_firehose_delivery_stream.audit_to_opensearch.name }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/${var.project}/audit"
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}

resource "aws_ecs_service" "audit" {
  name            = "${var.project}-audit"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.audit.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = [for s in aws_subnet.private : s.id]
    security_groups = [aws_security_group.tasks.id]
  }
  # optionally expose via ALB path /audit
}
