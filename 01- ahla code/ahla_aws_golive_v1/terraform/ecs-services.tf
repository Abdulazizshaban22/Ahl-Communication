resource "aws_iam_role" "task_exec" {
  name = "${var.project}-task-exec"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = { Service = "ecs-tasks.amazonaws.com" },
      Effect = "Allow"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "task_exec_logs" {
  role       = aws_iam_role.task_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Chat
resource "aws_ecs_task_definition" "chat" {
  family                   = "${var.project}-chat"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.task_exec.arn
  container_definitions = jsonencode([{
    name      = "chat"
    image     = var.image_chat
    essential = true
    portMappings = [{ containerPort = 3000, protocol = "tcp" }]
    environment = [
      { name = "REDIS_URL", value = "redis://dummy" } # replace with ElastiCache later
    ]
    healthCheck = {
      command     = ["CMD-SHELL","curl -f http://localhost:3000/health || exit 1"]
      interval    = 30
      timeout     = 5
      retries     = 3
      startPeriod = 10
    }
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/${var.project}/chat"
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}

resource "aws_ecs_service" "chat" {
  name            = "${var.project}-chat"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.chat.arn
  desired_count   = var.chat_desired
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = [for s in aws_subnet.private : s.id]
    security_groups = [aws_security_group.tasks.id]
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.tg_chat.arn
    container_name   = "chat"
    container_port   = 3000
  }
  lifecycle { ignore_changes = [desired_count] }
}

# Meet signaling
resource "aws_ecs_task_definition" "meet" {
  family                   = "${var.project}-meet"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.task_exec.arn
  container_definitions = jsonencode([{
    name      = "meet"
    image     = var.image_meet_signaling
    essential = true
    portMappings = [{ containerPort = 3001, protocol = "tcp" }]
    healthCheck = {
      command     = ["CMD-SHELL","curl -f http://localhost:3001/health || exit 1"]
      interval    = 30
      timeout     = 5
      retries     = 3
      startPeriod = 10
    }
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/${var.project}/meet"
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}

resource "aws_ecs_service" "meet" {
  name            = "${var.project}-meet"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.meet.arn
  desired_count   = 2
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = [for s in aws_subnet.private : s.id]
    security_groups = [aws_security_group.tasks.id]
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.tg_meet.arn
    container_name   = "meet"
    container_port   = 3001
  }
}

# Coturn as Fargate task (UDP 3478, TCP 5349)
resource "aws_ecs_task_definition" "coturn" {
  family                   = "${var.project}-coturn"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.task_exec.arn
  container_definitions = jsonencode([{
    name  = "coturn"
    image = var.image_coturn
    essential = true
    portMappings = [
      { containerPort = 3478, protocol = "udp" },
      { containerPort = 5349, protocol = "tcp" }
    ]
    command = ["-n","--log-file=stdout","--realm=${var.domain_root}","--min-port","49160","--max-port","49200","--no-cli"]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/${var.project}/coturn"
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}

resource "aws_ecs_service" "coturn" {
  name            = "${var.project}-coturn"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.coturn.arn
  desired_count   = 2
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = [for s in aws_subnet.private : s.id]
    security_groups = [aws_security_group.tasks.id]
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.tg_turn_udp.arn
    container_name   = "coturn"
    container_port   = 3478
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.tg_turn_tls.arn
    container_name   = "coturn"
    container_port   = 5349
  }
}
