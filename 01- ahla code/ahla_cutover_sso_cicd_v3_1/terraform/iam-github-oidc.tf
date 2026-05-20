data "aws_iam_policy_document" "gha_assume_role" {
  statement {
    effect = "Allow"
    principals { type = "Federated", identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"] }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.gh_owner}/${var.gh_repo}:ref:refs/heads/${var.gh_branch}"]
    }
  }
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "gha_ci" {
  name               = "${var.project}-gha-ci"
  assume_role_policy = data.aws_iam_policy_document.gha_assume_role.json
}

# Minimal ECR + Terraform permissions (adjust as needed)
data "aws_iam_policy_document" "gha_ci_policy" {
  statement { effect = "Allow", actions = ["ecr:GetAuthorizationToken"], resources = ["*"] }
  statement { effect = "Allow", actions = ["ecr:BatchGetImage","ecr:CompleteLayerUpload","ecr:DescribeImages","ecr:DescribeRepositories","ecr:GetDownloadUrlForLayer","ecr:InitiateLayerUpload","ecr:PutImage","ecr:UploadLayerPart","ecr:CreateRepository"], resources = ["*"] }
  statement { effect = "Allow", actions = ["iam:PassRole"], resources = ["*"] }
  statement { effect = "Allow", actions = ["sts:AssumeRole"], resources = ["*"] }
  statement { effect = "Allow", actions = ["ec2:Describe*","ecs:*","elasticloadbalancing:*","logs:*","cloudwatch:*","ssm:*","secretsmanager:*","s3:*","opensearch:*","firehose:*","route53:*","acm:*","cloudfront:*","grafana:*","iam:GetRole","iam:ListRoles","iam:CreateRole","iam:AttachRolePolicy","iam:PutRolePolicy"], resources = ["*"] }
}

resource "aws_iam_policy" "gha_ci_policy" {
  name   = "${var.project}-gha-ci-policy"
  policy = data.aws_iam_policy_document.gha_ci_policy.json
}
resource "aws_iam_role_policy_attachment" "gha_ci_attach" {
  role       = aws_iam_role.gha_ci.name
  policy_arn = aws_iam_policy.gha_ci_policy.arn
}
