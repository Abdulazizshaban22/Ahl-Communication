module "vpc" {
  source = "./modules/vpc"
  project = var.project
  vpc_cidr = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}

module "ecr" {
  source = "./modules/ecr"
  project = var.project
  repos = ["reverse-proxy"]
}

module "iam" {
  source = "./modules/iam"
  project = var.project
}

module "alb" {
  source = "./modules/alb"
  project = var.project
  vpc_id = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnet_ids
  domain_name = var.domain_name
  certificate_arn = var.certificate_arn
}

module "ssm" {
  source = "./modules/ssm"
  project = var.project
  params = {
    "/ahla/REDIS_URL"  = "redis://redis:6379/0"
    "/ahla/MEILI_URL"  = "http://meilisearch:7700"
    "/ahla/MEILI_KEY"  = "masterKey"
  }
}

module "ecs" {
  source = "./modules/ecs"
  project = var.project
  cluster_name = "${var.project}-cluster"
  vpc_id = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnet_ids
  target_group_arn = module.alb.tg_http_arn
  execution_role_arn = module.iam.execution_role_arn
  task_role_arn      = module.iam.task_role_arn
  images = {
    reverse-proxy = "${module.ecr.repo_urls["reverse-proxy"]}:${var.container_image_tag}"
  }
}