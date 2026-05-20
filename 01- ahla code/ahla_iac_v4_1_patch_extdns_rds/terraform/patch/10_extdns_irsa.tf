
# ---------------- IRSA for ExternalDNS (Route53) ----------------

variable "domain"         { type = string }
variable "hosted_zone_id" { type = string }

data "aws_eks_cluster" "this_patch" { name = var.name != null ? "${var.name}-eks" : "ahla-eks" }
data "aws_eks_cluster_auth" "this_patch" { name = data.aws_eks_cluster.this_patch.name }

# EKS OIDC
data "aws_iam_openid_connect_provider" "oidc" {
  arn = data.aws_eks_cluster.this_patch.identity[0].oidc[0].issuer_arn
}

# Least‑privilege policy to a single hosted zone
data "aws_iam_policy_document" "external_dns" {
  statement {
    sid     = "ChangeRecordSets"
    actions = ["route53:ChangeResourceRecordSets"]
    resources = ["arn:aws:route53:::hostedzone/${var.hosted_zone_id}"]
  }
  statement {
    sid     = "ListZones"
    actions = ["route53:ListHostedZones","route53:ListResourceRecordSets"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "external_dns" {
  name        = "${var.name}-ExternalDNS"
  description = "ExternalDNS policy for ${var.hosted_zone_id}"
  policy      = data.aws_iam_policy_document.external_dns.json
}

resource "aws_iam_role" "external_dns" {
  name = "${var.name}-ExternalDNS-IRSA"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Federated = data.aws_iam_openid_connect_provider.oidc.arn },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "${trimprefix(data.aws_eks_cluster.this_patch.identity[0].oidc[0].issuer, "https://")}:sub" = "system:serviceaccount:ingress-nginx:external-dns"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "external_dns" {
  role       = aws_iam_role.external_dns.name
  policy_arn = aws_iam_policy.external_dns.arn
}

resource "kubernetes_service_account" "external_dns" {
  metadata {
    name      = "external-dns"
    namespace = "ingress-nginx"
    annotations = { "eks.amazonaws.com/role-arn" = aws_iam_role.external_dns.arn }
  }
}

resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  namespace  = "ingress-nginx"
  version    = "1.15.0"

  set { name = "provider.name"; value = "aws" }
  set { name = "policy"; value = "upsert-only" }
  set { name = "domainFilters[0]"; value = var.domain }
  # Bind to IRSA ServiceAccount
  set { name = "serviceAccount.create"; value = "false" }
  set { name = "serviceAccount.name";   value = kubernetes_service_account.external_dns.metadata[0].name }
  set { name = "txtOwnerId"; value = "${var.name}-externaldns" }
  set { name = "registry"; value = "txt" }
}
