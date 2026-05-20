terraform {
  required_providers { aws = { source = "hashicorp/aws", version = "~> 5.0" } }
}
provider "aws" { region = var.region }
resource "aws_s3_bucket" "ahla_backup" { bucket = var.bucket_name }
resource "aws_s3_bucket_versioning" "v" { bucket = aws_s3_bucket.ahla_backup.id versioning_configuration { status = "Enabled" } }
resource "aws_s3_bucket_server_side_encryption_configuration" "enc" {
  bucket = aws_s3_bucket.ahla_backup.id
  rule { apply_server_side_encryption_by_default { sse_algorithm = "AES256" } }
}
resource "aws_s3_bucket_lifecycle_configuration" "lc" {
  bucket = aws_s3_bucket.ahla_backup.id
  rule {
    id = "expire-old"
    status = "Enabled"
    expiration { days = 180 }
  }
}
