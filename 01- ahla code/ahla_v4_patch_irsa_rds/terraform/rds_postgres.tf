
# --- RDS PostgreSQL (Multi‑AZ) + optional RDS Proxy ---

variable "db_instance_class"        { type = string, default = "db.m6i.large" }
variable "db_allocated_storage"     { type = number, default = 100 }
variable "db_max_allocated_storage" { type = number, default = 500 }
variable "db_engine_version"        { type = string, default = "15.5" }
variable "db_username"              { type = string, default = "app_user" }
variable "db_password"              { type = string, sensitive = true, default = "change_me_strong" }
variable "enable_rds_proxy"         { type = bool, default = true }

# VPC from EKS
data "aws_eks_cluster" "this_rds" { name = "${var.name}-eks" }

# SG for RDS
resource "aws_security_group" "rds" {
  name        = "${var.name}-rds-sg"
  description = "Allow DB access from EKS nodes"
  vpc_id      = data.aws_eks_cluster.this_rds.vpc_config[0].vpc_id
}

resource "aws_security_group_rule" "rds_ingress_pg" {
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  security_group_id = aws_security_group.rds.id
  cidr_blocks       = ["10.0.0.0/8"] # NOTE: ضيّقها لاحقًا إلى SG العقد.
}

# Subnets: استخدم مجموعة الشبكات الخاصة بـ EKS (أضبطها حسب بيئتك)
data "aws_subnets" "vpc_subnets" {
  filter { name = "vpc-id"; values = [data.aws_eks_cluster.this_rds.vpc_config[0].vpc_id] }
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-db-subnets"
  subnet_ids = data.aws_subnets.vpc_subnets.ids
}

resource "aws_db_parameter_group" "pg" {
  name   = "${var.name}-pg15"
  family = "postgres15"
}

resource "aws_db_instance" "postgres" {
  identifier                 = "${var.name}-pg"
  engine                     = "postgres"
  engine_version             = var.db_engine_version
  instance_class             = var.db_instance_class
  username                   = var.db_username
  password                   = var.db_password
  allocated_storage          = var.db_allocated_storage
  max_allocated_storage      = var.db_max_allocated_storage
  storage_encrypted          = true
  multi_az                   = true
  db_subnet_group_name       = aws_db_subnet_group.this.name
  vpc_security_group_ids     = [aws_security_group.rds.id]
  apply_immediately          = true
  backup_retention_period    = 7
  deletion_protection        = true
  skip_final_snapshot        = false
  parameter_group_name       = aws_db_parameter_group.pg.name
  publicly_accessible        = false
}

# Optional RDS Proxy
resource "aws_iam_role" "rds_proxy" {
  count = var.enable_rds_proxy ? 1 : 0
  name  = "${var.name}-RDSProxyRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{ Effect = "Allow", Principal = { Service = "rds.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
}

resource "aws_db_proxy" "pg" {
  count                  = var.enable_rds_proxy ? 1 : 0
  name                   = "${var.name}-pg-proxy"
  engine_family          = "POSTGRESQL"
  role_arn               = aws_iam_role.rds_proxy[0].arn
  vpc_security_group_ids = [aws_security_group.rds.id]
  vpc_subnet_ids         = aws_db_subnet_group.this.subnet_ids
  require_tls            = true
}

resource "aws_db_proxy_default_target_group" "pg" {
  count          = var.enable_rds_proxy ? 1 : 0
  db_proxy_name  = aws_db_proxy.pg[0].name
}

resource "aws_db_proxy_target" "pg" {
  count                 = var.enable_rds_proxy ? 1 : 0
  db_proxy_name         = aws_db_proxy.pg[0].name
  target_group_name     = aws_db_proxy_default_target_group.pg[0].name
  db_instance_identifier = aws_db_instance.postgres.id
}

# DB URL K8s Secret
resource "kubernetes_namespace" "system_ns" { metadata { name = "ahla-system" } }

locals {
  db_host = var.enable_rds_proxy ? aws_db_proxy.pg[0].endpoint : aws_db_instance.postgres.address
  db_url  = "postgresql://${var.db_username}:${var.db_password}@${local.db_host}:5432/ahla"
}

resource "kubernetes_secret" "db_url" {
  metadata { name = "db-url", namespace = kubernetes_namespace.system_ns.metadata[0].name }
  data = { url = base64encode(local.db_url) }
  type = "Opaque"
}

output "db_url"    { value = local.db_url, sensitive = true }
output "db_host"   { value = local.db_host }
output "db_secret" { value = "ahla-system/db-url" }
