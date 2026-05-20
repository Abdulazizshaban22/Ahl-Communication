
# --- S3 bucket for ALB access logs
variable "alb_logs_bucket" { default = "ahla-alb-logs" }
variable "alb_arn" {}

resource "aws_s3_bucket" "alb_logs" {
  bucket        = var.alb_logs_bucket
  force_destroy = true
}

# Grant ALB permission to write logs into the bucket
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

# (Manual step) — enable access_logs in your ALB module/resource:
# resource "aws_lb" "this" {
#   ...
#   access_logs {
#     bucket  = aws_s3_bucket.alb_logs.id
#     enabled = true
#   }
# }

# Lambda role for forwarding S3 ALB logs to Firehose
resource "aws_iam_role" "alb_s3_to_firehose_role" {
  name = "ahla-alb-s3-to-firehose"
  assume_role_policy = jsonencode({
    Version="2012-10-17",
    Statement=[{
      Effect="Allow", Principal={ Service="lambda.amazonaws.com" }, Action="sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "alb_s3_to_firehose_policy" {
  name = "ahla-alb-s3-to-firehose-policy"
  role = aws_iam_role.alb_s3_to_firehose_role.id
  policy = jsonencode({
    Version="2012-10-17",
    Statement=[
      { Effect="Allow", Action=["logs:CreateLogGroup","logs:CreateLogStream","logs:PutLogEvents"], Resource="*" },
      { Effect="Allow", Action=["s3:GetObject"], Resource=["${aws_s3_bucket.alb_logs.arn}/*"] },
      { Effect="Allow", Action=["firehose:PutRecord","firehose:PutRecordBatch"], Resource=aws_kinesis_firehose_delivery_stream.logs_to_os.arn }
    ]
  })
}

# Lambda function (Python) — reads S3 object and sends lines to Firehose
resource "aws_lambda_function" "alb_s3_to_firehose" {
  function_name = "ahla-alb-s3-to-firehose"
  role          = aws_iam_role.alb_s3_to_firehose_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  filename      = "${path.module}/lambda_alb_s3_to_firehose.zip"
  timeout       = 60
  environment {
    variables = {
      FIREHOSE_STREAM = aws_kinesis_firehose_delivery_stream.logs_to_os.name
    }
  }
}

# Package the lambda code from adjacent file (use local_file + null_resource if needed)
# For simplicity, commit the ZIP alongside this TF.

# S3 event notification → Lambda
resource "aws_s3_bucket_notification" "alb_logs_events" {
  bucket = aws_s3_bucket.alb_logs.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.alb_s3_to_firehose.arn
    events              = ["s3:ObjectCreated:*"]
  }
  depends_on = [ aws_lambda_permission.allow_s3_invoke ]
}

resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.alb_s3_to_firehose.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.alb_logs.arn
}
