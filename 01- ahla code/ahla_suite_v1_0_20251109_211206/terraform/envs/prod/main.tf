
module "alb" {
  source           = "../../modules/alb"
  vpc_id           = var.vpc_id
  public_subnets   = var.public_subnets
  certificate_arn  = var.certificate_arn
  domain_name      = var.domain_name
  route53_zone_id  = var.route53_zone_id
}

resource "aws_ecs_cluster" "this" { name = "ahla-cluster" }

resource "aws_security_group" "tasks" {
  name   = "ahla-tasks-sg"
  vpc_id = var.vpc_id
  ingress { from_port = 0, to_port = 65535, protocol = "tcp", security_groups = [module.alb.sg_alb_id] }
  egress  { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
}

# web apps
module "svc_chat_web" {
  source             = "../../modules/ecs_service"
  cluster_arn        = aws_ecs_cluster.this.arn
  service_name       = "chat-web"
  container_name     = "chat-web"
  image              = var.img_chat_web
  port               = 3000
  env                = { NEXT_PUBLIC_BASE_PATH="/chat" }
  secrets            = [
    { name="VAPID_PUBLIC_KEY",  valueFrom=var.ssm_vapid_pub },
    { name="VAPID_PRIVATE_KEY", valueFrom=var.ssm_vapid_priv }
  ]
  sg_tasks_id        = aws_security_group.tasks.id
  private_subnets    = var.private_subnets
  listener_https_arn = module.alb.listener_https_arn
  vpc_id             = var.vpc_id
  enable_codedeploy  = true
}

module "svc_meet_web" {
  source             = "../../modules/ecs_service"
  cluster_arn        = aws_ecs_cluster.this.arn
  service_name       = "meet-web"
  container_name     = "meet-web"
  image              = var.img_meet_web
  port               = 3100
  env                = { NEXT_PUBLIC_BASE_PATH="/meet" }
  sg_tasks_id        = aws_security_group.tasks.id
  private_subnets    = var.private_subnets
  listener_https_arn = module.alb.listener_https_arn
  vpc_id             = var.vpc_id
}

module "svc_drive_web" {
  source             = "../../modules/ecs_service"
  cluster_arn        = aws_ecs_cluster.this.arn
  service_name       = "drive-web"
  container_name     = "drive-web"
  image              = var.img_drive_web
  port               = 3200
  env                = { NEXT_PUBLIC_BASE_PATH="/drive" }
  sg_tasks_id        = aws_security_group.tasks.id
  private_subnets    = var.private_subnets
  listener_https_arn = module.alb.listener_https_arn
  vpc_id             = var.vpc_id
}

module "svc_business_web" {
  source             = "../../modules/ecs_service"
  cluster_arn        = aws_ecs_cluster.this.arn
  service_name       = "business-web"
  container_name     = "business-web"
  image              = var.img_business_web
  port               = 3300
  env                = { NEXT_PUBLIC_BASE_PATH="/business" }
  sg_tasks_id        = aws_security_group.tasks.id
  private_subnets    = var.private_subnets
  listener_https_arn = module.alb.listener_https_arn
  vpc_id             = var.vpc_id
}

# apis
module "svc_chat_api" {
  source             = "../../modules/ecs_service"
  cluster_arn        = aws_ecs_cluster.this.arn
  service_name       = "chat-api"
  container_name     = "chat-api"
  image              = var.img_chat_api
  port               = 8000
  sg_tasks_id        = aws_security_group.tasks.id
  private_subnets    = var.private_subnets
  listener_https_arn = module.alb.listener_https_arn
  vpc_id             = var.vpc_id
}

module "svc_meet_api" {
  source             = "../../modules/ecs_service"
  cluster_arn        = aws_ecs_cluster.this.arn
  service_name       = "meet-api"
  container_name     = "meet-api"
  image              = var.img_meet_api
  port               = 8100
  sg_tasks_id        = aws_security_group.tasks.id
  private_subnets    = var.private_subnets
  listener_https_arn = module.alb.listener_https_arn
  vpc_id             = var.vpc_id
}

module "svc_drive_api" {
  source             = "../../modules/ecs_service"
  cluster_arn        = aws_ecs_cluster.this.arn
  service_name       = "drive-api"
  container_name     = "drive-api"
  image              = var.img_drive_api
  port               = 8200
  sg_tasks_id        = aws_security_group.tasks.id
  private_subnets    = var.private_subnets
  listener_https_arn = module.alb.listener_https_arn
  vpc_id             = var.vpc_id
}

module "svc_business_api" {
  source             = "../../modules/ecs_service"
  cluster_arn        = aws_ecs_cluster.this.arn
  service_name       = "business-api"
  container_name     = "business-api"
  image              = var.img_business_api
  port               = 8300
  sg_tasks_id        = aws_security_group.tasks.id
  private_subnets    = var.private_subnets
  listener_https_arn = module.alb.listener_https_arn
  vpc_id             = var.vpc_id
}

module "svc_emotion_engine" {
  source             = "../../modules/ecs_service"
  cluster_arn        = aws_ecs_cluster.this.arn
  service_name       = "emotion-engine"
  container_name     = "emotion-engine"
  image              = var.img_emotion_engine
  port               = 8400
  sg_tasks_id        = aws_security_group.tasks.id
  private_subnets    = var.private_subnets
  listener_https_arn = module.alb.listener_https_arn
  vpc_id             = var.vpc_id
}

output "alb_dns" { value = module.alb.alb_dns_name }
