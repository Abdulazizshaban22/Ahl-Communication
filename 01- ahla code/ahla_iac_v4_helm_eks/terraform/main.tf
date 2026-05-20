
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
    kubernetes = { source = "hashicorp/kubernetes", version = "~> 2.30" }
    helm = { source = "hashicorp/helm", version = "~> 2.13" }
  }
}

provider "aws" {
  region = var.region
}

# --- VPC (terraform-aws-modules/vpc) ---
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.name}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.region}a","${var.region}b","${var.region}c"]
  private_subnets = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24","10.0.102.0/24","10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = { "kubernetes.io/cluster/${var.name}-eks" = "shared", "kubernetes.io/role/elb" = "1" }
  private_subnet_tags = { "kubernetes.io/cluster/${var.name}-eks" = "shared", "kubernetes.io/role/internal-elb" = "1" }
}

# --- EKS Cluster (terraform-aws-modules/eks) ---
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  cluster_name    = "${var.name}-eks"
  cluster_version = "1.29"

  vpc_id  = module.vpc.vpc_id
  subnet_ids = concat(module.vpc.private_subnets, module.vpc.public_subnets)

  enable_irsa = true

  eks_managed_node_groups = {
    default = {
      min_size     = 2
      max_size     = 6
      desired_size = 3
      instance_types = ["m6i.large"]
    }
  }

  tags = { Project = var.name }
}

data "aws_eks_cluster" "this" {
  name = module.eks.cluster_name
}
data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

# --- Namespaces ---
resource "kubernetes_namespace" "apps" { metadata { name = "ahla-apps" } }
resource "kubernetes_namespace" "system" { metadata { name = "ahla-system" } }
resource "kubernetes_namespace" "ingress_nginx" { metadata { name = "ingress-nginx" } }
resource "kubernetes_namespace" "cert_manager" { metadata { name = "cert-manager" } }
resource "kubernetes_namespace" "monitoring" { metadata { name = "monitoring" } }

# --- cert-manager (ACME HTTP-01) ---
resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = kubernetes_namespace.cert_manager.metadata[0].name
  version    = "v1.15.3"

  set {
    name  = "installCRDs"
    value = "true"
  }
}

# --- NGINX Ingress ---
resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = kubernetes_namespace.ingress_nginx.metadata[0].name
  version    = "4.11.2"
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "nlb"
  }
}

# --- ExternalDNS (Route53) ---
resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  namespace  = kubernetes_namespace.ingress_nginx.metadata[0].name
  version    = "1.15.0"
  set { name = "provider.name"; value = "aws" }
  set { name = "policy"; value = "upsert-only" }
  set { name = "domainFilters[0]"; value = var.domain }
  set { name = "txtOwnerId"; value = "${var.name}-external-dns" }
}

# --- kube-prometheus-stack (Prometheus/Grafana/Alertmanager) ---
resource "helm_release" "kube_prom_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  version    = "58.3.5"
  values = [file("${path.module}/values/kube-prometheus-values.yaml")]
}

# --- NATS (official chart) ---
resource "helm_release" "nats" {
  name       = "nats"
  repository = "https://nats-io.github.io/k8s/helm/charts/"
  chart      = "nats"
  namespace  = kubernetes_namespace.system.metadata[0].name
  version    = "1.3.15"
  values = [file("${path.module}/values/nats-values.yaml")]
}

# --- PostgreSQL (Bitnami) ---
resource "helm_release" "postgresql" {
  name       = "postgresql"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  namespace  = kubernetes_namespace.system.metadata[0].name
  version    = "14.2.7"
  values = [file("${path.module}/values/postgresql-values.yaml")]
}

# --- MinIO (Bitnami) ---
resource "helm_release" "minio" {
  name       = "minio"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "minio"
  namespace  = kubernetes_namespace.system.metadata[0].name
  version    = "12.10.9"
  values = [file("${path.module}/values/minio-values.yaml")]
}

# --- Mobile WS Gateway (local chart) ---
resource "helm_release" "mobile_gateway" {
  name       = "mobile-gateway"
  chart      = "${path.module}/../charts/mobile-gateway"
  namespace  = kubernetes_namespace.apps.metadata[0].name
  set { name = "image.repository"; value = var.mobile_gateway_image_repo }
  set { name = "image.tag"; value = var.mobile_gateway_image_tag }
  set { name = "env.NATS_URL"; value = "nats://nats.ahla-system.svc.cluster.local:4222" }
  set { name = "ingress.hosts[0]"; value = "mobile-gateway.${var.domain}" }
  depends_on = [helm_release.ingress_nginx, helm_release.cert_manager]
}

# --- ClusterIssuer (Let's Encrypt HTTP-01) ---
resource "kubernetes_manifest" "cluster_issuer" {
  manifest = yamldecode(templatefile("${path.module}/manifests/cluster-issuer.yaml", {
    email = var.acme_email
  }))
  depends_on = [helm_release.cert_manager]
}
