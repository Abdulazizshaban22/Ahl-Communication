
variable "alb_logs_bucket" { default = "ahla-alb-logs" }

resource "aws_s3_bucket" "alb_logs" {
  bucket        = var.alb_logs_bucket
  force_destroy = true
}

data "aws_elb_service_account" "main" {}

resource "aws_s3_bucket_policy" "alb_logs_policy" {
  bucket = aws_s3_bucket.alb_logs.id
  policy = jsonencode({
    Version="2012-10-17",
    Statement=[
      {
        Effect="Allow",
        Principal={ AWS = data.aws_elb_service_account.main.arn },
        Action=[ "s3:PutObject" ],
        Resource=[ "${aws_s3_bucket.alb_logs.arn}/*" ]
      }
    ]
  })
}

output "alb_logs_bucket_name" { value = aws_s3_bucket.alb_logs.bucket }
output "alb_logs_bucket_arn"  { value = aws_s3_bucket.alb_logs.arn }
