data "archive_file" "incident_indexer_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda/incident_indexer"
  output_path = "${path.module}/../lambda/incident_indexer.zip"
}

resource "aws_lambda_function" "incident_indexer" {
  function_name = "${var.project}-incident-indexer"
  role          = aws_iam_role.incident_indexer_role.arn
  handler       = "main.handler"
  runtime       = "python3.12"
  filename      = data.archive_file.incident_indexer_zip.output_path
  timeout       = 30

  environment {
    variables = {
      OPENSEARCH_ENDPOINT = var.opensearch_endpoint != null ? var.opensearch_endpoint : ""
      OPENSEARCH_INDEX    = var.opensearch_index
      AUTH_MODE           = var.opensearch_auth_mode
      BASIC_USER          = var.opensearch_basic_user
      BASIC_PASS          = var.opensearch_basic_pass
    }
  }
}

# Subscribe Lambda to SLO SNS topic
resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.incident_indexer.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.sns_topic_arn
}

resource "aws_sns_topic_subscription" "incident_lambda_sub" {
  topic_arn = var.sns_topic_arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.incident_indexer.arn
}
