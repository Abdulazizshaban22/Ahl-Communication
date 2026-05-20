
module "alb" {
  source           = "../../modules/alb"
  vpc_id           = var.vpc_id
  public_subnets   = var.public_subnets
  certificate_arn  = var.certificate_arn
  domain_name      = var.domain_name
  route53_zone_id  = var.route53_zone_id
}

resource "aws_ecs_cluster" "this" { name = "ahla-cluster" }

# Tasks SG
resource "aws_security_group" "tasks" {
  name   = "ahla-tasks-sg"
  vpc_id = var.vpc_id
  ingress { from_port = 0, to_port = 65535, protocol = "tcp", security_groups = [module.alb.sg_alb_id] }
  egress  { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
}

# ElastiCache Redis
module "redis" {
  source          = "../../modules/elasticache"
  vpc_id          = var.vpc_id
  private_subnets = var.private_subnets
  allowed_sg_id   = aws_security_group.tasks.id
}

# Web apps
module "svc_chat_web" {
  source             = "../../modules/ecs_service"
  aws_region         = var.region
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
  log_group_name     = "/ecs/ahla/chat-web"
  sg_tasks_id        = aws_security_group.tasks.id
  private_subnets    = var.private_subnets
  listener_https_arn = module.alb.listener_https_arn
  vpc_id             = var.vpc_id
  enable_codedeploy  = true
}

module "svc_meet_web" {
  source             = "../../modules/ecs_service"
  aws_region         = var.region
  cluster_arn        = aws_ecs_cluster.this.arn
  service_name       = "meet-web"
  container_name     = "meet-web"
  image              = var.img_meet_web
  port               = 3100
  env                = { NEXT_PUBLIC_BASE_PATH="/meet" }
  log_group_name     = "/ecs/ahla/meet-web"
  sg_tasks_id        = aws_security_group.tasks.id
  private_subnets    = var.private_subnets
  listener_https_arn = module.alb.listener_https_arn
  vpc_id             = var.vpc_id
}

# APIs
module "svc_chat_api" {
  source             = "../../modules/ecs_service"
  aws_region         = var.region
  cluster_arn        = aws_ecs_cluster.this.arn
  service_name       = "chat-api"
  container_name     = "chat-api"
  image              = var.img_chat_api
  port               = 8000
  env                = { REDIS_URL = "redis://${module.redis.redis_endpoint}:6379/0", ATTACH_STORE="/data" }
  log_group_name     = "/ecs/ahla/chat-api"
  sg_tasks_id        = aws_security_group.tasks.id
  private_subnets    = var.private_subnets
  listener_https_arn = module.alb.listener_https_arn
  vpc_id             = var.vpc_id
}

module "svc_meet_api" {
  source             = "../../modules/ecs_service"
  aws_region         = var.region
  cluster_arn        = aws_ecs_cluster.this.arn
  service_name       = "meet-api"
  container_name     = "meet-api"
  image              = var.img_meet_api
  port               = 8100
  env                = { STUN_URL="stun:stun.l.google.com:19302", TURN_URL="turn:turn.${var.domain_name}:3478", TURN_USER="ahla", TURN_PASS="ahla123" }
  log_group_name     = "/ecs/ahla/meet-api"
  sg_tasks_id        = aws_security_group.tasks.id
  private_subnets    = var.private_subnets
  listener_https_arn = module.alb.listener_https_arn
  vpc_id             = var.vpc_id
}

module "svc_emotion_engine" {
  source             = "../../modules/ecs_service"
  aws_region         = var.region
  cluster_arn        = aws_ecs_cluster.this.arn
  service_name       = "emotion-engine"
  container_name     = "emotion-engine"
  image              = var.img_emotion_engine
  port               = 8400
  log_group_name     = "/ecs/ahla/emotion-engine"
  sg_tasks_id        = aws_security_group.tasks.id
  private_subnets    = var.private_subnets
  listener_https_arn = module.alb.listener_https_arn
  vpc_id             = var.vpc_id
}

module "svc_push_worker" {
  source             = "../../modules/ecs_service"
  aws_region         = var.region
  cluster_arn        = aws_ecs_cluster.this.arn
  service_name       = "push-worker"
  container_name     = "push-worker"
  image              = var.img_push_worker
  port               = 8787
  env                = { REDIS_URL = "redis://${module.redis.redis_endpoint}:6379/0" }
  log_group_name     = "/ecs/ahla/push-worker"
  sg_tasks_id        = aws_security_group.tasks.id
  private_subnets    = var.private_subnets
  listener_https_arn = module.alb.listener_https_arn
  vpc_id             = var.vpc_id
}

# TURN via NLB
module "turn_nlb" {
  source          = "../../modules/nlb_turn"
  vpc_id          = var.vpc_id
  public_subnets  = var.public_subnets
  target_sg_id    = aws_security_group.tasks.id
  domain_name     = var.domain_name
  route53_zone_id = var.route53_zone_id
}

# Coturn ECS Service (UDP/TCP 3478) - uses NLB target groups
module "svc_turn" {
  source             = "../../modules/ecs_service"
  aws_region         = var.region
  cluster_arn        = aws_ecs_cluster.this.arn
  service_name       = "turn"
  container_name     = "coturn"
  image              = "coturn/coturn:latest"
  port               = 3478
  protocol           = "UDP"
  assign_public_ip   = false
  env                = {}
  log_group_name     = "/ecs/ahla/turn"
  sg_tasks_id        = aws_security_group.tasks.id
  private_subnets    = var.private_subnets
  listener_https_arn = module.alb.listener_https_arn
  vpc_id             = var.vpc_id
}

# Attach service to NLB target groups is not directly expressed via ECS module;
# Use aws_lb_target_group_attachment to register IP targets from ECS tasks via service discovery.
# For simplicity in this scaffold, advise using Fargate with awsvpc and target_type=ip; dynamic targets will register automatically if service is created with 'load_balancer' referencing NLB TGs.
# (Out of scope for a minimal static module; in practice, define a dedicated module for NLB-attached ECS services.)

# Alarms
module "alerts" {
  source          = "../../modules/alarms"
  cluster_name    = aws_ecs_cluster.this.name
  service_names   = [ module.svc_chat_web.svc_name, module.svc_meet_web.svc_name, module.svc_chat_api.svc_name, module.svc_meet_api.svc_name, module.svc_emotion_engine.svc_name, module.svc_push_worker.svc_name ]
  alb_arn_suffix  = module.alb.alb_arn_suffix
  sns_email       = var.alerts_email
}

output "alb_dns" { value = module.alb.alb_dns_name }
output "turn_nlb_dns" { value = module.turn_nlb.nlb_dns }
