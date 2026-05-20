# IAM role for rotation Lambda
resource "aws_iam_role" "rotation_role" {
  name = "${var.project}-rotation-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "rotation_policy" {
  name = "${var.project}-rotation-policy"
  role = aws_iam_role.rotation_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      { Effect: "Allow", Action: ["logs:CreateLogGroup","logs:CreateLogStream","logs:PutLogEvents"], Resource: "arn:aws:logs:*:*:*" },
      { Effect: "Allow", Action: ["secretsmanager:GetSecretValue","secretsmanager:PutSecretValue","secretsmanager:UpdateSecretVersionStage","secretsmanager:DescribeSecret"], Resource: var.rds_secret_arn },
      { Effect: "Allow", Action: ["rds:DescribeDBInstances"], Resource: "*" },
      { Effect: "Allow", Action: ["ec2:CreateNetworkInterface","ec2:DescribeNetworkInterfaces","ec2:DeleteNetworkInterface"], Resource: "*" }
    ]
  })
}

resource "aws_lambda_function" "rds_rotation" {
  function_name = "${var.project}-rds-rotation"
  role          = aws_iam_role.rotation_role.arn
  handler       = "rotation.lambda_handler"
  runtime       = "python3.11"
  timeout       = 300
  filename      = "${path.module}/../lambda/rotation_rds_singleuser.zip"
  vpc_config {
    subnet_ids         = var.lambda_subnet_ids
    security_group_ids = var.lambda_security_group_ids
  }
  environment {
    variables = {
      RDS_INSTANCE_ID = var.rds_instance_id
    }
  }
}

resource "aws_secretsmanager_secret_rotation" "rds_secret_rotation" {
  secret_id           = var.rds_secret_arn
  rotation_lambda_arn = aws_lambda_function.rds_rotation.arn
  rotation_rules { automatically_after_days = 30 }
}
