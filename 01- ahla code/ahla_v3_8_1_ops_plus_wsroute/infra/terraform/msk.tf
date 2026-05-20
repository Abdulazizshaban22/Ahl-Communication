resource "aws_msk_serverless_cluster" "this" {
  cluster_name = var.msk_cluster_name
  vpc_config {
    subnet_ids = var.private_subnets
    security_group_ids = [aws_security_group.ecs_sg.id]
  }
  client_authentication {
    sasl {
      iam = true
    }
  }
  tags = { Project = var.project }
}
output "msk_bootstrap_brokers_sasl_iam" {
  value = aws_msk_serverless_cluster.this.bootstrap_brokers_sasl_iam
}
