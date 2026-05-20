locals { name = var.project }
data "aws_availability_zones" "azs" {}

# VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.1"
  name = "${local.name}-vpc"
  cidr = var.vpc_cidr
  azs  = slice(data.aws_availability_zones.azs.names, 0, var.az_count)
  private_subnets = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 4, i)]
  public_subnets  = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 4, i + 8)]
  enable_nat_gateway = true
  single_nat_gateway = true
  tags = { Project = local.name }
}

# KMS & Secrets
resource "aws_kms_key" "secrets" { description = "${local.name} secrets"; enable_key_rotation = true }
resource "aws_secretsmanager_secret" "db_pass"  { name = "${local.name}/db/password"; kms_key_id = aws_kms_key.secrets.arn }
resource "aws_secretsmanager_secret_version" "db_pass" { secret_id = aws_secretsmanager_secret.db_pass.id secret_string = var.db_password }

# RDS Postgres 16
resource "aws_security_group" "db" {
  name = "${local.name}-db-sg"
  vpc_id = module.vpc.vpc_id
  ingress { from_port=5432 to_port=5432 protocol="tcp" security_groups=[aws_security_group.ecs_tasks.id] }
  egress  { from_port=0 to_port=0 protocol="-1" cidr_blocks=["0.0.0.0/0"] }
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.6.0"
  identifier = "${local.name}-pg"
  engine = "postgres"
  engine_version = "16.3"
  instance_class = var.db_instance_class
  allocated_storage = 50
  db_name  = "aif"
  username = var.db_username
  password = var.db_password
  multi_az = true
  storage_encrypted = true
  kms_key_id = aws_kms_key.secrets.arn
  deletion_protection = true
  publicly_accessible = false
  vpc_security_group_ids = [aws_security_group.db.id]
  subnet_ids = module.vpc.private_subnets
  family    = "postgres16"
  major_engine_version = "16"
  manage_master_user_password = false
  tags = { Project = local.name }
}

# MSK
resource "aws_security_group" "msk" {
  name = "${local.name}-msk-sg"
  vpc_id = module.vpc.vpc_id
  ingress { from_port=0 to_port=0 protocol="-1" security_groups=[aws_security_group.ecs_tasks.id] }
  egress  { from_port=0 to_port=0 protocol="-1" cidr_blocks=["0.0.0.0/0"] }
}

# serverless-iam
resource "aws_msk_serverless_cluster" "serverless" {
  count = var.msk_mode == "serverless-iam" ? 1 : 0
  cluster_name = var.msk_cluster_name
  vpc_config { subnet_ids = module.vpc.private_subnets security_group_ids = [aws_security_group.msk.id] }
  client_authentication { sasl { iam = true } }
  tags = { Project = local.name }
}

# provisioned-scram (minimal example; tweak for prod quotas)
resource "aws_msk_cluster" "provisioned" {
  count = var.msk_mode == "provisioned-scram" ? 1 : 0
  cluster_name           = var.msk_cluster_name
  kafka_version          = "3.6.0"
  number_of_broker_nodes = var.az_count
  broker_node_group_info {
    instance_type   = "kafka.m5.large"
    client_subnets  = module.vpc.private_subnets
    security_groups = [aws_security_group.msk.id]
  }
  client_authentication {
    sasl { scram = true }
  }
  encryption_info { encryption_in_transit { client_broker = "TLS" in_cluster = true } }
  tags = { Project = local.name }
}

# ECS
resource "aws_ecs_cluster" "this" {
  name = "${local.name}-ecs"
  setting { name = "containerInsights" value = "enabled" }
  configuration { execute_command_configuration { logging = "DEFAULT" } }
  tags = { Project = local.name }
}

resource "aws_security_group" "ecs_tasks" {
  name   = "${local.name}-ecs-tasks"
  vpc_id = module.vpc.vpc_id
  egress { from_port=0 to_port=0 protocol="-1" cidr_blocks=["0.0.0.0/0"] }
}

# Public ALB (for CloudFront origin)
resource "aws_security_group" "alb" {
  name   = "${local.name}-alb"
  vpc_id = module.vpc.vpc_id
  egress  { from_port=0 to_port=0 protocol="-1" cidr_blocks=["0.0.0.0/0"] }
}

# Restrict ALB to CloudFront origin-facing prefix list
data "aws_prefix_list" "cloudfront_origin_ipv4" { name = "com.amazonaws.global.cloudfront.origin-facing" }
resource "aws_security_group_rule" "alb_from_cf_http" {
  type = "ingress"
  security_group_id = aws_security_group.alb.id
  from_port = 80
  to_port   = 80
  protocol  = "tcp"
  prefix_list_ids = [data.aws_prefix_list.cloudfront_origin_ipv4.id]
  description = "Allow only CloudFront origin-facing to ALB:80"
}

resource "aws_lb" "public" {
  name               = "${local.name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = module.vpc.public_subnets
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
  load_balancer_arn = aws_lb.public.arn
  port = 80
  protocol = "HTTP"
  default_action { type = "forward" target_group_arn = aws_lb_target_group.orchestrator.arn }
}

# CloudFront + WAF (in us-east-1)
resource "aws_cloudfront_distribution" "aif_orchestrator" {
  enabled = true
  comment = "${var.project} — Orchestrator edge"
  origin {
    domain_name = aws_lb.public.dns_name
    origin_id   = "aif-orchestrator-alb"
    custom_header { name = "X-From-CloudFront" value = "true" }
    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }
  default_cache_behavior {
    allowed_methods  = ["GET","HEAD","OPTIONS","PUT","POST","PATCH","DELETE"]
    cached_methods   = ["GET","HEAD"]
    target_origin_id = "aif-orchestrator-alb"
    viewer_protocol_policy = "redirect-to-https"
    forwarded_values {
      query_string = true
      headers      = ["Authorization","Content-Type","X-From-CloudFront"]
      cookies { forward = "all" }
    }
    min_ttl = 0; default_ttl = 0; max_ttl = 0
  }
  restrictions { geo_restriction { restriction_type = "none" } }
  viewer_certificate { cloudfront_default_certificate = true }
}

resource "aws_wafv2_web_acl" "edge_acl" {
  provider = aws.use1
  name  = "${var.project}-edge-waf"
  scope = "CLOUDFRONT"
  default_action { allow {} }
  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 10
    statement { managed_rule_group_statement { name="AWSManagedRulesCommonRuleSet" vendor_name="AWS" } }
    override_action { none {} }
    visibility_config { cloudwatch_metrics_enabled=true metric_name="common" sampled_requests_enabled=true }
  }
  rule {
    name     = "AWS-BotControl"
    priority = 20
    statement { managed_rule_group_statement { name="AWSManagedRulesBotControlRuleSet" vendor_name="AWS" } }
    override_action { none {} }
    visibility_config { cloudwatch_metrics_enabled=true metric_name="bot" sampled_requests_enabled=true }
  }
  rule {
    name     = "AWS-ATP"
    priority = 30
    statement { managed_rule_group_statement { name="AWSManagedRulesATPRuleSet" vendor_name="AWS" } }
    override_action { none {} }
    visibility_config { cloudwatch_metrics_enabled=true metric_name="atp" sampled_requests_enabled=true }
  }
  visibility_config { cloudwatch_metrics_enabled=true metric_name="edge-waf" sampled_requests_enabled=true }
}

resource "aws_wafv2_web_acl_association" "edge_acl_assoc" {
  provider     = aws.use1
  resource_arn = aws_cloudfront_distribution.aif_orchestrator.arn
  web_acl_arn  = aws_wafv2_web_acl.edge_acl.arn
}

# Canary
resource "aws_synthetics_canary" "orch_health" {
  name                 = "${var.project}-orch-health"
  artifact_s3_location = "s3://synthetics-${var.project}/"
  execution_role_arn   = var.canary_role_arn
  runtime_version      = "syn-nodejs-puppeteer-7.0"
  handler              = "page.handler"
  start_canary         = true
  schedule { expression = "rate(1 minute)" }
  success_retention_period = 31
  failure_retention_period = 31
  run_config {
    timeout_in_seconds = 30
    memory_in_mb       = 960
    environment_variables = {
      URL = "https://${aws_cloudfront_distribution.aif_orchestrator.domain_name}/health"
      T_APDEX = "1.0"
    }
  }
  s3_bucket { bucket = "synthetics-${var.project}" }
  code {
    handler = "page.handler"
    script  = <<'EOT'
const synthetics = require('Synthetics');
const log = require('SyntheticsLogger');
const page = async function () {
  const url = process.env.URL;
  const start = Date.now();
  await synthetics.executeHttpStep('GET /health', url, { method: 'GET', timeout: 30000 });
  const dur = (Date.now() - start) / 1000.0;
  log.info(`duration=${dur}`);
};
exports.handler = async () => { return await page(); };
EOT
  }
}

# Alarms (Apdex approx + CloudFront 5xx)
resource "aws_cloudwatch_metric_alarm" "apdex_low" {
  alarm_name          = "${var.project}-apdex-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 5
  threshold           = 0.85
  treat_missing_data  = "breaching"
  metric_query {
    id="m1"; label="Duration"; return_data=false
    metric {
      metric_name = "Duration"
      namespace   = "CloudWatchSynthetics"
      period      = 60
      stat        = "Average"
      dimensions = { CanaryName = aws_synthetics_canary.orch_health.name }
    }
  }
  metric_query {
    id = "apdex"
    expression = "( IF(m1 < 1.0, 1, 0) + 0.5*IF(m1 >= 1.0 AND m1 < 4.0, 1, 0) )"
    label = "Apdex"
    return_data = true
  }
}

resource "aws_cloudwatch_metric_alarm" "cf_5xx_high" {
  alarm_name          = "${var.project}-cf-5xx-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  threshold           = 1.0
  treat_missing_data  = "notBreaching"
  metric_name         = "5xxErrorRate"
  namespace           = "AWS/CloudFront"
  statistic           = "Average"
  period              = 60
  dimensions = {
    DistributionId = aws_cloudfront_distribution.aif_orchestrator.id
    Region         = "Global"
  }
}

# ECR repos
resource "aws_ecr_repository" "orch" { name = var.ecr_repo_orchestrator image_scanning_configuration { scan_on_push = true } }
resource "aws_ecr_repository" "wrk"  { name = var.ecr_repo_workers      image_scanning_configuration { scan_on_push = true } }

# Roles
resource "aws_iam_role" "task_exec" {
  name = "${local.name}-task-exec"
  assume_role_policy = jsonencode({
    Version="2012-10-17",
    Statement=[{Effect="Allow", Principal={Service="ecs-tasks.amazonaws.com"}, Action="sts:AssumeRole"}]
  })
}
resource "aws_iam_role" "task_role" {
  name = "${local.name}-task-role"
  assume_role_policy = jsonencode({
    Version="2012-10-17",
    Statement=[{Effect="Allow", Principal={Service="ecs-tasks.amazonaws.com"}, Action="sts:AssumeRole"}]
  })
}
resource "aws_cloudwatch_log_group" "aif" { name = "/ecs/${local.name}" retention_in_days = 30 }

locals {
  image_orchestrator = "${aws_ecr_repository.orch.repository_url}:prod"
  image_workers      = "${aws_ecr_repository.wrk.repository_url}:prod"
}

# Orchestrator task/service
resource "aws_ecs_task_definition" "orchestrator" {
  family = "${local.name}-orchestrator"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "512"; memory = "1024"
  execution_role_arn = aws_iam_role.task_exec.arn
  task_role_arn      = aws_iam_role.task_role.arn
  container_definitions = jsonencode([{
    name="orchestrator", image=local.image_orchestrator, essential=true,
    portMappings=[{containerPort=8000, protocol="tcp"}],
    environment=[
      { name="PGHOST", value=module.db.db_instance_address },
      { name="PGPORT", value="5432" },
      { name="PGDATABASE", value="aif" },
      { name="PGUSER", value=var.db_username },
      { name="PGVECTOR_DIM", value="768" },
      { name="AUTH_MODE", value=var.msk_mode == "serverless-iam" ? "iam" : "scram" },
      { name="KAFKA_BOOTSTRAP", value=var.msk_mode == "serverless-iam" ? aws_msk_serverless_cluster.serverless[0].bootstrap_brokers_sasl_iam : aws_msk_cluster.provisioned[0].bootstrap_brokers_sasl_scram }
    ],
    secrets=[{ name="PGPASSWORD", valueFrom=aws_secretsmanager_secret.db_pass.arn }],
    logConfiguration={ logDriver="awslogs", options={
      awslogs-group=aws_cloudwatch_log_group.aif.name, awslogs-region=var.region, awslogs-stream-prefix="orchestrator"
    }}
  }])
}
resource "aws_ecs_service" "orchestrator" {
  name = "${local.name}-orchestrator"
  cluster = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.orchestrator.arn
  desired_count = 2
  launch_type   = "FARGATE"
  network_configuration { subnets=module.vpc.private_subnets security_groups=[aws_security_group.ecs_tasks.id] assign_public_ip=false }
  load_balancer { target_group_arn=aws_lb_target_group.orchestrator.arn container_name="orchestrator" container_port=8000 }
  deployment_circuit_breaker { enable=true rollback=true }
  depends_on = [aws_lb_listener.http]
}

# Workers task/service (4 services)
resource "aws_ecs_task_definition" "workers" {
  family = "${local.name}-workers"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "512"; memory = "1024"
  execution_role_arn = aws_iam_role.task_exec.arn
  task_role_arn      = aws_iam_role.task_role.arn
  container_definitions = jsonencode([{
    name="workers", image=local.image_workers, essential=true,
    environment=[
      { name="PGHOST", value=module.db.db_instance_address },
      { name="PGPORT", value="5432" },
      { name="PGDATABASE", value="aif" },
      { name="PGUSER", value=var.db_username },
      { name="PGVECTOR_DIM", value="768" },
      { name="AUTH_MODE", value=var.msk_mode == "serverless-iam" ? "iam" : "scram" },
      { name="KAFKA_BOOTSTRAP", value=var.msk_mode == "serverless-iam" ? aws_msk_serverless_cluster.serverless[0].bootstrap_brokers_sasl_iam : aws_msk_cluster.provisioned[0].bootstrap_brokers_sasl_scram }
    ],
    logConfiguration={ logDriver="awslogs", options={
      awslogs-group=aws_cloudwatch_log_group.aif.name, awslogs-region=var.region, awslogs-stream-prefix="workers"
    }}
  }])
}
resource "aws_ecs_service" "w_emb" { name="${local.name}-w-embeddings" cluster=aws_ecs_cluster.this.id task_definition=aws_ecs_task_definition.workers.arn desired_count=1 launch_type="FARGATE" network_configuration { subnets=module.vpc.private_subnets security_groups=[aws_security_group.ecs_tasks.id] assign_public_ip=false } }
resource "aws_ecs_service" "w_emo" { name="${local.name}-w-emotion"    cluster=aws_ecs_cluster.this.id task_definition=aws_ecs_task_definition.workers.arn desired_count=1 launch_type="FARGATE" network_configuration { subnets=module.vpc.private_subnets security_groups=[aws_security_group.ecs_tasks.id] assign_public_ip=false } }
resource "aws_ecs_service" "w_ana" { name="${local.name}-w-analyzer"   cluster=aws_ecs_cluster.this.id task_definition=aws_ecs_task_definition.workers.arn desired_count=1 launch_type="FARGATE" network_configuration { subnets=module.vpc.private_subnets security_groups=[aws_security_group.ecs_tasks.id] assign_public_ip=false } }
resource "aws_ecs_service" "w_talk"{ name="${local.name}-w-talk"       cluster=aws_ecs_cluster.this.id task_definition=aws_ecs_task_definition.workers.arn desired_count=1 launch_type="FARGATE" network_configuration { subnets=module.vpc.private_subnets security_groups=[aws_security_group.ecs_tasks.id] assign_public_ip=false } }

output "cloudfront_domain_name" { value = aws_cloudfront_distribution.aif_orchestrator.domain_name }
output "orchestrator_alb_dns"   { value = aws_lb.public.dns_name }
output "db_endpoint"            { value = module.db.db_instance_address }
output "msk_bootstrap_sasl_iam" { value = try(aws_msk_serverless_cluster.serverless[0].bootstrap_brokers_sasl_iam, "") }
output "msk_bootstrap_scram"    { value = try(aws_msk_cluster.provisioned[0].bootstrap_brokers_sasl_scram, "") }
