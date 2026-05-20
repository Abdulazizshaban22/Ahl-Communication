resource "aws_s3_bucket" "drive" {
  bucket = var.s3_bucket
  force_destroy = false
  tags = { Project = var.project, Service = "drive" }
}

resource "aws_s3_bucket_public_access_block" "drive" {
  bucket = aws_s3_bucket.drive.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_cors_configuration" "drive" {
  bucket = aws_s3_bucket.drive.id
  cors_rule {
    allowed_methods = ["GET","PUT","HEAD"]
    allowed_origins = var.cors_allowed_origins
    allowed_headers = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3600
  }
}

# Optional: enforce TLS for S3 access and restrict to your VPC or IAM role
data "aws_iam_policy_document" "drive_policy" {
  statement {
    sid = "DenyInsecureTransport"
    effect = "Deny"
    principals { type = "*", identifiers = ["*"] }
    actions   = ["s3:*"]
    resources = [aws_s3_bucket.drive.arn, "${aws_s3_bucket.drive.arn}/*"]
    condition {
      test = "Bool"
      variable = "aws:SecureTransport"
      values = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "drive" {
  bucket = aws_s3_bucket.drive.id
  policy = data.aws_iam_policy_document.drive_policy.json
}
