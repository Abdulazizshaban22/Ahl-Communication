# Task role allowing drive-api to use the S3 bucket
resource "aws_iam_role" "drive_task_role" {
  name = "${var.project}-drive-task-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ecs-tasks.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

data "aws_iam_policy_document" "drive_access" {
  statement {
    effect = "Allow"
    actions = ["s3:PutObject","s3:GetObject","s3:DeleteObject","s3:AbortMultipartUpload","s3:ListBucketMultipartUploads"]
    resources = ["${aws_s3_bucket.drive.arn}/*"]
  }
  statement {
    effect = "Allow"
    actions = ["s3:ListBucket"]
    resources = [aws_s3_bucket.drive.arn]
  }
}

resource "aws_iam_policy" "drive_access" {
  name   = "${var.project}-drive-s3-policy"
  policy = data.aws_iam_policy_document.drive_access.json
}

resource "aws_iam_role_policy_attachment" "drive_access" {
  role       = aws_iam_role.drive_task_role.name
  policy_arn = aws_iam_policy.drive_access.arn
}
