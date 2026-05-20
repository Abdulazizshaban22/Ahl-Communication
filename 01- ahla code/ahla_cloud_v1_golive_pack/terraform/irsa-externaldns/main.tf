terraform {
  required_providers { aws = { source = "hashicorp/aws", version = "~> 5.0" } }
}
provider "aws" { region = var.region }
data "aws_iam_policy_document" "externaldns" {
  statement {
    effect = "Allow"
    actions = ["route53:ChangeResourceRecordSets"]
    resources = ["arn:aws:route53:::hostedzone/${var.zone_id}"]
  }
  statement {
    effect = "Allow"
    actions = ["route53:ListHostedZones","route53:ListResourceRecordSets"]
    resources = ["*"]
  }
}
resource "aws_iam_policy" "externaldns" {
  name   = "ExternalDNSPolicy"
  policy = data.aws_iam_policy_document.externaldns.json
}
# Attach this to a Kubernetes service account via IRSA (OIDC provider required)
