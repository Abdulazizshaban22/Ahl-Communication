resource "aws_s3_bucket" "canary_code" {
  bucket = var.canary_bucket_name
}

resource "aws_s3_object" "canary_zip" {
  bucket = aws_s3_bucket.canary_code.id
  key    = "ahla-canary.zip"
  source = "${path.module}/../canaries/ahla-canary.zip"
  etag   = filemd5("${path.module}/../canaries/ahla-canary.zip")
}

resource "aws_iam_role" "canary_role" {
  name = "${var.project}-canary-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "canary_policy" {
  name = "${var.project}-canary-policy"
  role = aws_iam_role.canary_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      { Effect: "Allow", Action: ["logs:CreateLogGroup","logs:CreateLogStream","logs:PutLogEvents"], Resource: "arn:aws:logs:*:*:*" },
      { Effect: "Allow", Action: ["s3:GetObject","s3:ListBucket"], Resource: ["${aws_s3_bucket.canary_code.arn}", "${aws_s3_bucket.canary_code.arn}/*"] }
    ]
  })
}

locals {
  endpoints = {
    chat  = "${var.test_base_url}/chat"
    meet  = "${var.test_base_url}/meet"
    drive = "${var.test_base_url}/drive"
  }
}

# Helper to create 3 canaries
resource "aws_synthetics_canary" "ahla" {
  for_each             = local.endpoints
  name                 = "${var.project}-canary-${each.key}"
  artifact_s3_location = "s3://${aws_s3_bucket.canary_code.bucket}/"
  execution_role_arn   = aws_iam_role.canary_role.arn
  handler              = "index.handler"
  runtime_version      = "syn-nodejs-puppeteer-6.2"
  schedule { expression = "rate(5 minutes)" }
  start_canary         = true
  s3_bucket            = aws_s3_bucket.canary_code.id
  s3_key               = aws_s3_object.canary_zip.key
  success_retention_period = 31
  failure_retention_period = 90
  run_config {
    environment_variables = { TEST_URL = each.value }
  }
  tags = { Project = var.project }
}
