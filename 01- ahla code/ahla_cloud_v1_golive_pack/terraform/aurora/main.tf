terraform {
  required_providers { aws = { source = "hashicorp/aws", version = "~> 5.0" } }
}
provider "aws" { region = var.region }
resource "aws_rds_cluster" "ahla" {
  cluster_identifier      = "ahla-aurora"
  engine                  = "aurora-postgresql"
  engine_version          = "15.4"
  database_name           = "ahla"
  master_username         = var.master_username
  master_password         = var.master_password
  backup_retention_period = 7
  preferred_backup_window = "03:00-04:00"
  copy_tags_to_snapshot   = true
}
resource "aws_rds_cluster_instance" "ahla_instances" {
  count                = 2
  identifier           = "ahla-aurora-${count.index}"
  cluster_identifier   = aws_rds_cluster.ahla.id
  instance_class       = "db.r6g.large"
  engine               = aws_rds_cluster.ahla.engine
  engine_version       = aws_rds_cluster.ahla.engine_version
}
output "database_url" {
  value = "postgresql://${var.master_username}:${var.master_password}@${aws_rds_cluster.ahla.endpoint}:5432/ahla"
  sensitive = true
}
