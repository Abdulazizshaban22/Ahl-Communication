# Enable versioning
resource "aws_s3_bucket_versioning" "drive_versioning" {
  bucket = var.s3_drive_bucket
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_lifecycle_configuration" "drive_lifecycle" {
  bucket = var.s3_drive_bucket
  rule {
    id     = "expire-noncurrent"
    status = "Enabled"
    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
  rule {
    id     = "transition-ia"
    status = "Enabled"
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}

# Logs bucket lifecycle
resource "aws_s3_bucket_versioning" "logs_versioning" {
  bucket = var.s3_logs_bucket
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_lifecycle_configuration" "logs_lifecycle" {
  bucket = var.s3_logs_bucket
  rule {
    id     = "expire-logs"
    status = "Enabled"
    expiration {
      days = 365
    }
  }
}
