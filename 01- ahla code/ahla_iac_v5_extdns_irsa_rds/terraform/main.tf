
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws        = { source = "hashicorp/aws", version = "~> 5.0" }
    kubernetes = { source = "hashicorp/kubernetes", version = "~> 2.30" }
    helm       = { source = "hashicorp/helm", version = "~> 2.13" }
  }
}

provider "aws" { region = var.region }

# Existing VPC/EKS are assumed created (from v4). Fetch cluster for providers.
data "aws_eks_cluster" "this" { name = "${var.name}-eks" }
data "aws_eks_cluster_auth" "this" { name = "${var.name}-eks" }

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

# ---------------- Namespaces ----------------
resource "kubernetes_namespace" "ingress_nginx" { metadata { name = "ingress-nginx" } }
resource "kubernetes_namespace" "apps"          { metadata { name = "ahla-apps" } }
resource "kubernetes_namespace" "system"        { metadata { name = "ahla-system" } }

# ---------------- IRSA for ExternalDNS ----------------
# Docs: ExternalDNS AWS policy (Route53 change/list) & IRSA for EKS.
#  - ExternalDNS IAM policy: https://kubernetes-sigs.github.io/external-dns/latest/docs/tutorials/aws/
#  - IRSA: https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html

# OIDC provider ARN for the EKS cluster
data "aws_iam_openid_connect_provider" "oidc" {
  arn = data.aws_eks_cluster.this.identity[0].oidc[0].issuer_arn
}

# IAM policy limited to specific hosted zone
data "aws_iam_policy_document" "external_dns" {
  statement {
    sid = "ChangeRecordSets"
    actions = ["route53:ChangeResourceRecordSets"]
    resources = ["arn:aws:route53:::hostedzone/${var.hosted_zone_id}"]
  }
  statement {
    sid = "ListZones"
    actions = ["route53:ListHostedZones","route53:ListResourceRecordSets"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "external_dns" {
  name        = "${var.name}-ExternalDNS"
  description = "ExternalDNS policy to manage Route53 in ${var.hosted_zone_id}"
  policy      = data.aws_iam_policy_document.external_dns.json
}

resource "aws_iam_role" "external_dns" {
  name = "${var.name}-ExternalDNS-IRSA"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Federated = data.aws_iam_openid_connect_provider.oidc.arn },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "${trimprefix(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://")}:sub" = "system:serviceaccount:ingress-nginx:external-dns"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "external_dns" {
  role       = aws_iam_role.external_dns.name
  policy_arn = aws_iam_policy.external_dns.arn
}

# ServiceAccount annotated with role ARN
resource "kubernetes_service_account" "external_dns" {
  metadata {
    name      = "external-dns"
    namespace = kubernetes_namespace.ingress_nginx.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.external_dns.arn
    }
  }
}

# Helm release of external-dns bound to the SA
resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  namespace  = kubernetes_namespace.ingress_nginx.metadata[0].name
  version    = "1.15.0"

  set { name = "provider.name"; value = "aws" }
  set { name = "policy"; value = "upsert-only" }
  set { name = "domainFilters[0]"; value = var.domain }
  set { name = "serviceAccount.create"; value = "false" }
  set { name = "serviceAccount.name";   value = kubernetes_service_account.external_dns.metadata[0].name }
  set { name = "txtOwnerId"; value = "${var.name}-externaldns" }
  set { name = "registry"; value = "txt" }
}

# ---------------- Amazon RDS for PostgreSQL ----------------
# Docs:
#  - RDS Postgres & Multi-AZ: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.MultiAZ.html
#  - RDS Proxy (optional):   https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/rds-proxy.html

# VPC selection (from EKS cluster subnets). For simplicity, reuse public/ private from the cluster.
# In real setups, you should pass VPC/subnet IDs explicitly.
data "aws_subnets" "all" { filter { name = "vpc-id", values = [data.aws_eks_cluster.this.vpc_config[0].vpc_id] } }

# Security group for RDS allowing traffic from worker nodes
resource "aws_security_group" "rds" {
  name        = "${var.name}-rds-sg"
  description = "Allow DB access from EKS nodes"
  vpc_id      = data.aws_eks_cluster.this.vpc_config[0].vpc_id
}

# Allow Postgres from cluster CIDRs
resource "aws_security_group_rule" "rds_ingress_pg" {
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  security_group_id = aws_security_group.rds.id
  cidr_blocks       = data.aws_eks_cluster.this.vpc_config[0].cluster_security_group_id != "" ? null : ["10.0.0.0/8"]
  # NOTE: Adjust source to node groups SGs in production for least privilege.
}

# DB subnet group (choose private subnets by tag or naming; here we select all private subnets of EKS VPC)
resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-db-subnets"
  subnet_ids = [for s in data.aws_subnets.all.ids : s]
}

resource "aws_db_parameter_group" "pg" {
  name   = "${var.name}-pg15"
  family = "postgres15"
  description = "Ahla Postgres 15 parameter group"
  # Example: track_activities = on, etc.
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
  performance_insights_enabled = true
  backup_retention_period    = 7
  deletion_protection        = true
  skip_final_snapshot        = false
  parameter_group_name       = aws_db_parameter_group.pg.name
  publicly_accessible        = false
}

# Optional: RDS Proxy
resource "aws_db_proxy" "pg" {
  count               = var.enable_rds_proxy ? 1 : 0
  name                = "${var.name}-pg-proxy"
  engine_family       = "POSTGRESQL"
  role_arn            = aws_iam_role.rds_proxy[0].arn
  vpc_security_group_ids = [aws_security_group.rds.id]
  vpc_subnet_ids      = aws_db_subnet_group.this.subnet_ids
  require_tls         = true
}

resource "aws_iam_role" "rds_proxy" {
  count = var.enable_rds_proxy ? 1 : 0
  name  = "${var.name}-RDSProxyRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{ Effect = "Allow", Principal = { Service = "rds.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
}

resource "aws_db_proxy_default_target_group" "pg" {
  count        = var.enable_rds_proxy ? 1 : 0
  db_proxy_name = aws_db_proxy.pg[0].name
}

resource "aws_db_proxy_target" "pg" {
  count                = var.enable_rds_proxy ? 1 : 0
  db_proxy_name        = aws_db_proxy.pg[0].name
  target_group_name    = aws_db_proxy_default_target_group.pg[0].name
  db_instance_identifier = aws_db_instance.postgres.id
}

# K8s Secret with DB URL (points to RDS endpoint or Proxy if enabled)
locals {
  db_host = var.enable_rds_proxy ? aws_db_proxy.pg[0].endpoint : aws_db_instance.postgres.address
  db_url  = "postgresql://${var.db_username}:${var.db_password}@${local.db_host}:5432/ahla"
}

resource "kubernetes_secret" "db_url" {
  metadata { name = "db-url", namespace = kubernetes_namespace.system.metadata[0].name }
  data = { url = base64encode(local.db_url) }
  type = "Opaque"
}
