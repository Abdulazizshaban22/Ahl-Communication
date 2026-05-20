# Synthetics Canary (upload code zip to S3 first)
resource "aws_s3_bucket" "canary_code" {
  bucket = "${var.project}-canary-code"
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

resource "aws_synthetics_canary" "ahla" {
  name                 = "${var.project}-canary"
  artifact_s3_location = "s3://${aws_s3_bucket.canary_code.bucket}/"
  execution_role_arn   = aws_iam_role.canary_role.arn
  handler              = "index.handler"
  runtime_version      = "syn-nodejs-puppeteer-6.2"
  schedule {
    expression = "rate(5 minutes)"
  }
  start_canary = true
  s3_bucket    = aws_s3_bucket.canary_code.id
  s3_key       = aws_s3_object.canary_zip.key
  success_retention_period = 31
  failure_retention_period = 90
  tags = { Project = var.project }
}
