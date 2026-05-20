
variable "opensearch_domain_name" { default = "ahla-logs" }

resource "aws_opensearch_domain" "logs" {
  domain_name = var.opensearch_domain_name
  engine_version = "OpenSearch_2.11"
  cluster_config {
    instance_type = "t3.small.search"
    instance_count = 2
    zone_awareness_enabled = true
  }
  ebs_options { ebs_enabled=true, volume_size=20, volume_type="gp3" }
  encrypt_at_rest { enabled=true }
  node_to_node_encryption { enabled=true }
  domain_endpoint_options { enforce_https=true, tls_security_policy="Policy-Min-TLS-1-2-2019-07" }
  advanced_security_options {
    enabled = true
    internal_user_database_enabled = true
    master_user_options { master_user_name="admin", master_user_password="ChangeMe123!" }
  }
  tags = { Project="Ahla", Purpose="Logs" }
}

output "opensearch_endpoint" { value = aws_opensearch_domain.logs.endpoint }
