resource "aws_msk_serverless_cluster" "this" {
  cluster_name = "${var.name_prefix}-msk"
  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }
  client_authentication {
    sasl { iam = true }
  }
  tags = { Project = var.name_prefix }
}

# Topics are created at runtime by producers with IAM auth; optionally define them using external tools.
output "bootstrap_brokers_sasl_iam" {
  value = aws_msk_serverless_cluster.this.bootstrap_brokers_sasl_iam
}
