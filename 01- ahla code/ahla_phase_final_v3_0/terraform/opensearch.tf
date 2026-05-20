resource "aws_opensearch_domain" "audit" {
  domain_name    = var.opensearch_domain_name
  engine_version = "OpenSearch_2.13"
  cluster_config {
    instance_type = var.opensearch_instance_type
    instance_count = 1
    zone_awareness_enabled = false
  }
  ebs_options { ebs_enabled = true volume_size = 20 volume_type = "gp3" }
  encrypt_at_rest { enabled = true }
  node_to_node_encryption { enabled = true }
  domain_endpoint_options { enforce_https = true tls_security_policy = "Policy-Min-TLS-1-2-2019-07" }
}

resource "aws_s3_bucket" "audit_backup" {
  bucket = var.audit_s3_bucket
  force_destroy = false
}

resource "aws_iam_role" "firehose_role" {
  name = "${var.project}-firehose-os-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "firehose.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "firehose_policy" {
  name = "${var.project}-firehose-os-policy"
  role = aws_iam_role.firehose_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      { Effect: "Allow", Action: ["es:DescribeDomain","es:DescribeElasticsearchDomain","es:ESHttpPost","es:ESHttpPut","es:ESHttpGet"], Resource: "${aws_opensearch_domain.audit.arn}/*" },
      { Effect: "Allow", Action: ["s3:AbortMultipartUpload","s3:GetBucketLocation","s3:GetObject","s3:ListBucket","s3:ListBucketMultipartUploads","s3:PutObject"], Resource: ["${aws_s3_bucket.audit_backup.arn}","${aws_s3_bucket.audit_backup.arn}/*"] },
      { Effect: "Allow", Action: ["lambda:InvokeFunction","lambda:GetFunctionConfiguration"], Resource: "*" },
      { Effect: "Allow", Action: ["logs:PutLogEvents"], Resource: "*" }
    ]
  })
}

resource "aws_kinesis_firehose_delivery_stream" "audit_to_opensearch" {
  name        = "${var.project}-audit-firehose"
  destination = "opensearch"
  opensearch_configuration {
    domain_arn        = aws_opensearch_domain.audit.arn
    index_name        = "audit-events"
    role_arn          = aws_iam_role.firehose_role.arn
    s3_backup_mode    = "AllDocuments"
    type_name         = "_doc"
  }
  s3_configuration {
    role_arn           = aws_iam_role.firehose_role.arn
    bucket_arn         = aws_s3_bucket.audit_backup.arn
    buffering_interval = 300
    buffering_size     = 5
    compression_format = "GZIP"
  }
}
output "audit_firehose_name" { value = aws_kinesis_firehose_delivery_stream.audit_to_opensearch.name }
output "opensearch_endpoint" { value = aws_opensearch_domain.audit.endpoint }
