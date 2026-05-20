
# Kinesis Firehose delivery from CloudWatch Logs to OpenSearch
variable "firehose_stream_name" { default = "ahla-logs-to-os" }
variable "logs_groups" {
  type = list(string)
  default = [
    "/ecs/ahla/chat-web",
    "/ecs/ahla/meet-web",
    "/ecs/ahla/drive-web",
    "/ecs/ahla/business-web",
    "/ecs/ahla/mail-web",
    "/ecs/ahla/chat-api",
    "/ecs/ahla/meet-api",
    "/ecs/ahla/drive-api",
    "/ecs/ahla/business-api",
    "/ecs/ahla/mail-api",
    "/ecs/ahla/emotion-engine",
    "/ecs/ahla/push-worker"
  ]
}

resource "aws_s3_bucket" "firehose_backup" {
  bucket = "ahla-firehose-backup-${var.region}"
  force_destroy = true
}

resource "aws_iam_role" "firehose_role" {
  name = "ahla-firehose-to-opensearch"
  assume_role_policy = jsonencode({
    Version="2012-10-17",
    Statement=[{
      Effect="Allow", Principal={Service="firehose.amazonaws.com"},
      Action="sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "firehose_policy" {
  name = "ahla-firehose-policy"
  policy = jsonencode({
    Version="2012-10-17",
    Statement=[
      { Effect="Allow", Action=["es:DescribeElasticsearchDomain","es:DescribeElasticsearchDomains","es:DescribeElasticsearchDomainConfig"], Resource="*" },
      { Effect="Allow", Action=["es:ESHttpPost","es:ESHttpPut","es:ESHttpGet"], Resource=aws_opensearch_domain.logs.arn },
      { Effect="Allow", Action=["s3:AbortMultipartUpload","s3:GetBucketLocation","s3:GetObject","s3:ListBucket","s3:ListBucketMultipartUploads","s3:PutObject"], Resource=["${aws_s3_bucket.firehose_backup.arn}","${aws_s3_bucket.firehose_backup.arn}/*"] },
      { Effect="Allow", Action=["logs:PutLogEvents"], Resource="*" }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "firehose_attach" {
  role       = aws_iam_role.firehose_role.name
  policy_arn = aws_iam_policy.firehose_policy.arn
}

resource "aws_kinesis_firehose_delivery_stream" "logs_to_os" {
  name        = var.firehose_stream_name
  destination = "opensearch"

  opensearch_configuration {
    domain_arn        = aws_opensearch_domain.logs.arn
    role_arn          = aws_iam_role.firehose_role.arn
    index_name        = "ahla-%{formatdate("YYYY-MM-dd", timestamp())}"
    s3_backup_mode    = "FailedDocumentsOnly"
    buffering_interval = 60
    buffering_size     = 5
    cloudwatch_logging_options { enabled=true, log_group_name="/ahla/firehose", log_stream_name="to-os" }
  }

  s3_configuration {
    role_arn           = aws_iam_role.firehose_role.arn
    bucket_arn         = aws_s3_bucket.firehose_backup.arn
    buffering_interval = 300
    buffering_size     = 5
    compression_format = "GZIP"
    cloudwatch_logging_options { enabled=true, log_group_name="/ahla/firehose", log_stream_name="s3-backup" }
  }
}

# Role for CloudWatch Logs to put to Firehose
resource "aws_iam_role" "logs_to_firehose_role" {
  name = "ahla-cwlogs-to-firehose"
  assume_role_policy = jsonencode({
    Version="2012-10-17",
    Statement=[{
      Effect="Allow", Principal={Service="logs.${var.region}.amazonaws.com"}, Action="sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "logs_to_firehose_policy" {
  name = "ahla-cwlogs-to-firehose-policy"
  role = aws_iam_role.logs_to_firehose_role.id
  policy = jsonencode({
    Version="2012-10-17",
    Statement=[{
      Effect="Allow", Action=["firehose:PutRecord","firehose:PutRecordBatch"], Resource=aws_kinesis_firehose_delivery_stream.logs_to_os.arn
    }]
  })
}

# Create subscription filters for each log group
resource "aws_cloudwatch_log_subscription_filter" "to_firehose" {
  for_each        = toset(var.logs_groups)
  name            = "to-firehose"
  log_group_name  = each.value
  destination_arn = aws_kinesis_firehose_delivery_stream.logs_to_os.arn
  role_arn        = aws_iam_role.logs_to_firehose_role.arn
  filter_pattern  = ""
}
