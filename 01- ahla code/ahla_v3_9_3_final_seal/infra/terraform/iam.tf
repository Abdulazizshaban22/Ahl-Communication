data "aws_iam_policy_document" "waf_switch" {
  statement {
    actions = ["wafv2:GetWebACL", "wafv2:UpdateWebACL", "wafv2:ListAvailableManagedRuleGroups", "wafv2:GetManagedRuleSet"]
    resources = ["*"]
  }
  statement {
    actions = ["logs:CreateLogGroup","logs:CreateLogStream","logs:PutLogEvents"]
    resources = ["*"]
  }
}

resource "aws_iam_role" "waf_switch_role" {
  name               = "${var.project}-waf-switch-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "waf_switch_policy" {
  name   = "${var.project}-waf-switch-policy"
  role   = aws_iam_role.waf_switch_role.id
  policy = data.aws_iam_policy_document.waf_switch.json
}

# Incident indexer
data "aws_iam_policy_document" "incident_indexer" {
  statement {
    actions = ["es:ESHttpPost","es:ESHttpPut","es:ESHttpGet","es:ESHttpPatch"]
    resources = ["*"]
  }
  statement {
    actions = ["secretsmanager:GetSecretValue","ssm:GetParameter","kms:Decrypt"]
    resources = ["*"]
  }
  statement {
    actions = ["logs:CreateLogGroup","logs:CreateLogStream","logs:PutLogEvents"]
    resources = ["*"]
  }
}

resource "aws_iam_role" "incident_indexer_role" {
  name               = "${var.project}-incident-indexer-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "incident_indexer_policy" {
  name   = "${var.project}-incident-indexer-policy"
  role   = aws_iam_role.incident_indexer_role.id
  policy = data.aws_iam_policy_document.incident_indexer.json
}
