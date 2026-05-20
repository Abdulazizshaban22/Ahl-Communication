# VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.5"
  name = "${var.project}-vpc"
  cidr = var.vpc_cidr
  azs  = var.azs
  public_subnets  = [for i in range(length(var.azs)) : cidrsubnet(var.vpc_cidr, 8, i)]
  private_subnets = [for i in range(length(var.azs)) : cidrsubnet(var.vpc_cidr, 8, i + 10)]
  enable_nat_gateway = true
  single_nat_gateway = true
}

# EKS
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.11"
  cluster_name    = "${var.project}-eks"
  cluster_version = var.eks_version
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets

  eks_managed_node_groups = {
    main = {
      instance_types = ["m6i.large"]
      desired_size = 3
      min_size     = 3
      max_size     = 10
    }
  }

  enable_irsa = true
}

# Aurora PostgreSQL (serverless v2 example)
module "aurora" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 9.7"
  name                = "${var.project}-aurora"
  engine              = "aurora-postgresql"
  engine_version      = var.db_engine_version
  master_username     = var.db_username
  master_password     = var.db_password
  database_name       = "ahladb"
  vpc_id              = module.vpc.vpc_id
  subnets             = module.vpc.private_subnets
  create_security_group = true
  serverlessv2_scaling_configuration = { min_capacity = 1, max_capacity = 8 }
}

output "eks_cluster_name" { value = module.eks.cluster_name }
output "aurora_endpoint"  { value = module.aurora.cluster_endpoint }
output "vpc_id"           { value = module.vpc.vpc_id }
