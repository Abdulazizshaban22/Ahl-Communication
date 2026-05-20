resource "aws_ecs_cluster" "this" {
  name = "${var.project}-cluster"
}

resource "aws_security_group" "alb_sg" {
  name   = "${var.project}-alb-sg"
  vpc_id = var.vpc_id
  ingress { from_port=80  to_port=80  protocol="tcp" cidr_blocks=["0.0.0.0/0"] }
  egress  { from_port=0   to_port=0   protocol="-1"  cidr_blocks=["0.0.0.0/0"] }
}
resource "aws_lb" "alb" {
  name               = "${var.project}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnets
}

resource "aws_security_group" "ecs_sg" {
  name   = "${var.project}-ecs-sg"
  vpc_id = var.vpc_id
  ingress { from_port=0 to_port=0 protocol="-1" security_groups=[aws_security_group.alb_sg.id] }
  egress  { from_port=0 to_port=0 protocol="-1" cidr_blocks=["0.0.0.0/0"] }
}

resource "aws_iam_role" "ecs_task_exec" {
  name = "${var.project}-ecs-task-exec"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "ecs-tasks.amazonaws.com" } }]
  })
}
resource "aws_iam_role_policy_attachment" "ecs_task_exec" {
  role       = aws_iam_role.ecs_task_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Target groups
resource "aws_lb_target_group" "tg_gateway" {
  name     = "${var.project}-tg-gw"
  port     = 8085
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"
  health_check { path="/health" }
}
resource "aws_lb_target_group" "tg_next" {
  name     = "${var.project}-tg-next"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"
  health_check { path="/" }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port = 80
  protocol = "HTTP"
  default_action { type = "forward" target_group_arn = aws_lb_target_group.tg_next.arn }
}

# Task Definitions
resource "aws_ecs_task_definition" "gateway" {
  family                   = "${var.project}-gateway"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = 512
  memory = 1024
  execution_role_arn = aws_iam_role.ecs_task_exec.arn
  container_definitions = jsonencode([{
    name      = "gateway"
    image     = var.image_gateway
    essential = true
    portMappings = [{containerPort=8085,hostPort=8085,protocol="tcp"}]
    environment = [
      {"name":"KAFKA_SECURITY_PROTOCOL","value":"SASL_SSL"},
      {"name":"KAFKA_SASL_MECHANISM","value":"OAUTHBEARER"},
      {"name":"AWS_REGION","value":var.region},
      {"name":"KAFKA_BROKERS","value":aws_msk_serverless_cluster.this.bootstrap_brokers_sasl_iam[0]}
    ]
    linuxParameters = {}
  }])
  runtime_platform { operating_system_family = "LINUX" cpu_architecture = "X86_64" }
}

resource "aws_ecs_task_definition" "next" {
  family                   = "${var.project}-next"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = 512
  memory = 1024
  execution_role_arn = aws_iam_role.ecs_task_exec.arn
  container_definitions = jsonencode([{
    name      = "next"
    image     = var.image_next
    essential = true
    portMappings = [{containerPort=3000,hostPort=3000,protocol="tcp"}]
    environment = [
      {"name":"GATEWAY_URL","value":"http://" + aws_lb.alb.dns_name + ":80"}
    ]
  }])
  runtime_platform { operating_system_family = "LINUX" cpu_architecture = "X86_64" }
}

# Services
resource "aws_ecs_service" "gateway" {
  name            = "${var.project}-gateway"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.gateway.arn
  desired_count   = 2
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.tg_gateway.arn
    container_name   = "gateway"
    container_port   = 8085
  }
}

resource "aws_ecs_service" "next" {
  name            = "${var.project}-next"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.next.arn
  desired_count   = 2
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.tg_next.arn
    container_name   = "next"
    container_port   = 3000
  }
}
