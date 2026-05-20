
terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
    kubernetes = { source = "hashicorp/kubernetes", version = "~> 2.30" }
  }
}

provider "aws" { region = var.region }

data "aws_eks_cluster" "this" { name = "${var.name}-eks" }
data "aws_eks_cluster_auth" "this" { name = data.aws_eks_cluster.this.name }

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

module "aurora" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 9.7"

  name           = "${var.name}-aurora-pg"
  engine         = "aurora-postgresql"
  engine_version = var.engine_version
  instances = { one = { instance_class = var.instance_class } }

  vpc_id  = var.vpc_id
  subnets = var.private_subnet_ids
  security_group_rules = {
    ingress = {
      cidr_blocks = var.ingress_cidrs
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "DB access from EKS"
    }
  }

  database_name   = "ahla"
  master_username = var.db_username
  master_password = var.db_password

  apply_immediately               = true
  create_random_password          = false
  backup_retention_period         = 7
  monitoring_interval             = 60
  enabled_cloudwatch_logs_exports = ["postgresql"]
}

locals {
  host  = module.aurora.cluster_endpoint
  dburl = "postgresql://${var.db_username}:${var.db_password}@${local.host}:5432/ahla"
}

resource "kubernetes_secret" "db_url" {
  metadata { name = "db-url", namespace = "ahla-system" }
  data = { url = base64encode(local.dburl) }
}
