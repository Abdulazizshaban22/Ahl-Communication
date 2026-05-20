locals {
  name = var.project
}

# ---- VPC ----
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.1"

  name = "${local.name}-vpc"
  cidr = var.vpc_cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, var.az_count)
  private_subnets = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 4, i)]
  public_subnets  = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 4, i + 8)]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = { Project = local.name }
}
data "aws_availability_zones" "available" {}

# ---- KMS + Secrets ----
resource "aws_kms_key" "secrets" { description = "${local.name} secrets"; enable_key_rotation = true }
resource "aws_secretsmanager_secret" "msk_user" { name = "${local.name}/msk/scram_user"; kms_key_id = aws_kms_key.secrets.arn }
resource "aws_secretsmanager_secret" "msk_pass" { name = "${local.name}/msk/scram_pass"; kms_key_id = aws_kms_key.secrets.arn }
resource "aws_secretsmanager_secret" "db_pass"  { name = "${local.name}/db/password";   kms_key_id = aws_kms_key.secrets.arn }

# ---- RDS PostgreSQL 16 (pgvector) ----
module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.6.0"

  identifier = "${local.name}-pg"

  engine            = "postgres"
  engine_version    = "16.3"
  instance_class    = var.db_instance_class
  allocated_storage = 50

  db_name  = "aif"
  username = var.db_username
  password = var.db_password

  multi_az               = true
  storage_encrypted      = true
  kms_key_id             = aws_kms_key.secrets.arn
  deletion_protection    = true
  publicly_accessible    = false

  vpc_security_group_ids = [aws_security_group.db.id]
  subnet_ids             = module.vpc.private_subnets

  family = "postgres16"
  major_engine_version = "16"

  manage_master_user_password = false

  tags = { Project = local.name }
}

resource "aws_security_group" "db" {
  name        = "${local.name}-db-sg"
  description = "RDS access"
  vpc_id      = module.vpc.vpc_id
  ingress { from_port = 5432 to_port = 5432 protocol = "tcp" security_groups = [aws_security_group.ecs_tasks.id] }
  egress  { from_port = 0 to_port = 0 protocol = "-1" cidr_blocks = ["0.0.0.0/0"] }
}

# ---- MSK Serverless (SASL/SCRAM placeholder) ----
resource "aws_security_group" "msk" {
  name        = "${local.name}-msk-sg"
  description = "MSK access"
  vpc_id      = module.vpc.vpc_id
  ingress { from_port = 0 to_port = 0 protocol = "-1" security_groups = [aws_security_group.ecs_tasks.id] }
  egress  { from_port = 0 to_port = 0 protocol = "-1" cidr_blocks = ["0.0.0.0/0"] }
}

resource "aws_msk_serverless_cluster" "this" {
  cluster_name = var.msk_cluster_name
  vpc_config {
    subnet_ids         = module.vpc.private_subnets
    security_group_ids = [aws_security_group.msk.id]
  }
  client_authentication {
    sasl {
      iam = true
    }
  }
  tags = { Project = local.name }
}

# ---- ECS cluster ----
resource "aws_ecs_cluster" "this" {
  name = "${local.name}-ecs"
  setting { name = "containerInsights" value = "enabled" }
  configuration { execute_command_configuration { logging = "DEFAULT" } }
  tags = { Project = local.name }
}

resource "aws_security_group" "ecs_tasks" {
  name   = "${local.name}-ecs-tasks"
  vpc_id = module.vpc.vpc_id
  egress { from_port = 0 to_port = 0 protocol = "-1" cidr_blocks = ["0.0.0.0/0"] }
}

# ---- ALB (internal) for Orchestrator ----
resource "aws_security_group" "alb" {
  name   = "${local.name}-alb"
  vpc_id = module.vpc.vpc_id
  ingress { from_port = 80 to_port = 80 protocol = "tcp" cidr_blocks = ["10.0.0.0/8"] } # internal only; adjust
  egress  { from_port = 0 to_port = 0 protocol = "-1" cidr_blocks = ["0.0.0.0/0"] }
}

resource "aws_lb" "internal" {
  name               = "${local.name}-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = module.vpc.private_subnets
  tags = { Project = local.name }
}

resource "aws_lb_target_group" "orchestrator" {
  name     = "${local.name}-tg-orch"
  port     = 8000
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = module.vpc.vpc_id
  health_check { path = "/health" matcher = "200" }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.internal.arn
  port = 80
  protocol = "HTTP"
  default_action { type = "forward" target_group_arn = aws_lb_target_group.orchestrator.arn }
}

# ---- ECR repos (optional) ----
resource "aws_ecr_repository" "orch" { name = var.ecr_repo_orchestrator image_scanning_configuration { scan_on_push = true } }
resource "aws_ecr_repository" "wrk"  { name = var.ecr_repo_workers      image_scanning_configuration { scan_on_push = true } }

# ---- Task Roles ----
resource "aws_iam_role" "task_exec" {
  name = "${local.name}-task-exec"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{ Effect = "Allow", Principal = { Service = "ecs-tasks.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
}
resource "aws_iam_role" "task_role" {
  name = "${local.name}-task-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{ Effect = "Allow", Principal = { Service = "ecs-tasks.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
}
resource "aws_iam_role_policy_attachment" "xray" {
  role       = aws_iam_role.task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}
resource "aws_cloudwatch_log_group" "aif" { name = "/ecs/${local.name}" retention_in_days = 30 }

# ---- Task Definitions (Orchestrator + Workers) ----
locals {
  image_orchestrator = "${aws_ecr_repository.orch.repository_url}:prod"
  image_workers      = "${aws_ecr_repository.wrk.repository_url}:prod"
}

resource "aws_ecs_task_definition" "orchestrator" {
  family                   = "${local.name}-orchestrator"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu    = "512"
  memory = "1024"
  execution_role_arn = aws_iam_role.task_exec.arn
  task_role_arn      = aws_iam_role.task_role.arn
  container_definitions = jsonencode([{
    name  = "orchestrator"
    image = local.image_orchestrator
    essential = true
    portMappings = [{ containerPort = 8000, protocol = "tcp" }]
    environment = [
      { name="KAFKA_BROKERS", value=aws_msk_serverless_cluster.this.bootstrap_brokers_sasl_iam },
      { name="PGHOST", value=module.db.db_instance_address },
      { name="PGPORT", value="5432" },
      { name="PGDATABASE", value="aif" },
      { name="PGUSER", value=var.db_username },
    ]
    secrets = [
      { name="PGPASSWORD", valueFrom=aws_secretsmanager_secret.db_pass.arn }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group = aws_cloudwatch_log_group.aif.name
        awslogs-region = var.region
        awslogs-stream-prefix = "orchestrator"
      }
    }
  }])
}

resource "aws_ecs_service" "orchestrator" {
  name            = "${local.name}-orchestrator"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.orchestrator.arn
  desired_count   = 2
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = module.vpc.private_subnets
    security_groups = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.orchestrator.arn
    container_name   = "orchestrator"
    container_port   = 8000
  }
  deployment_circuit_breaker { enable = true rollback = true }
  force_new_deployment = true
  depends_on = [aws_lb_listener.http]
}

# ---- Workers (single task def, multiple services with different commands/env if needed) ----
resource "aws_ecs_task_definition" "workers" {
  family                   = "${local.name}-workers"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu    = "512"
  memory = "1024"
  execution_role_arn = aws_iam_role.task_exec.arn
  task_role_arn      = aws_iam_role.task_role.arn
  container_definitions = jsonencode([{
    name  = "workers"
    image = local.image_workers
    essential = true
    environment = [
      { name="KAFKA_BROKERS", value=aws_msk_serverless_cluster.this.bootstrap_brokers_sasl_iam },
      { name="PGHOST", value=module.db.db_instance_address },
      { name="PGPORT", value="5432" },
      { name="PGDATABASE", value="aif" },
      { name="PGUSER", value=var.db_username },
      { name="PGVECTOR_DIM", value="768" }
    ]
    secrets = [{ name="PGPASSWORD", valueFrom=aws_secretsmanager_secret.db_pass.arn }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group = aws_cloudwatch_log_group.aif.name
        awslogs-region = var.region
        awslogs-stream-prefix = "workers"
      }
    }
  }])
}

# 4 ECS services, each overrides command via capacity providers/ENV at image level (simplified: create 4 services from same TD)
resource "aws_ecs_service" "worker_embeddings" {
  name            = "${local.name}-w-embeddings"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.workers.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration { subnets = module.vpc.private_subnets security_groups = [aws_security_group.ecs_tasks.id] assign_public_ip=false }
}

resource "aws_ecs_service" "worker_emotion" {
  name            = "${local.name}-w-emotion"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.workers.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration { subnets = module.vpc.private_subnets security_groups = [aws_security_group.ecs_tasks.id] assign_public_ip=false }
}

resource "aws_ecs_service" "worker_analyzer" {
  name            = "${local.name}-w-analyzer"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.workers.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration { subnets = module.vpc.private_subnets security_groups = [aws_security_group.ecs_tasks.id] assign_public_ip=false }
}

resource "aws_ecs_service" "worker_talk" {
  name            = "${local.name}-w-talk"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.workers.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration { subnets = module.vpc.private_subnets security_groups = [aws_security_group.ecs_tasks.id] assign_public_ip=false }
}

output "orchestrator_internal_alb_dns" { value = aws_lb.internal.dns_name }
output "db_endpoint" { value = module.db.db_instance_address }
output "msk_bootstrap_sasl_iam" { value = aws_msk_serverless_cluster.this.bootstrap_brokers_sasl_iam }
