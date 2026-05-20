
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

# === Services ===
module "svc_chat_web" {
  source             = "../../modules/ecs_service"
  cluster_arn        = aws_ecs_cluster.this.arn
  service_name       = "chat-web"
  container_name     = "chat-web"
  image              = var.img_chat_web
  port               = 3000
  env                = { NEXT_PUBLIC_BASE_PATH = "/chat" }
  secrets            = [
    { name = "VAPID_PUBLIC_KEY",  valueFrom = var.ssm_vapid_pub  },
    { name = "VAPID_PRIVATE_KEY", valueFrom = var.ssm_vapid_priv }
  ]
  sg_tasks_id        = aws_security_group.tasks.id
  private_subnets    = var.private_subnets
  alb_arn            = module.alb.alb_arn
  listener_https_arn = module.alb.listener_https_arn
  listener_test_arn  = module.alb.listener_test_arn
  vpc_id             = var.vpc_id
  enable_codedeploy  = true
}

module "svc_chat_api" {
  source             = "../../modules/ecs_service"
  cluster_arn        = aws_ecs_cluster.this.arn
  service_name       = "api-chat"
  container_name     = "chat-api"
  image              = var.img_chat_api
  port               = 8000
  env                = {}
  sg_tasks_id        = aws_security_group.tasks.id
  private_subnets    = var.private_subnets
  alb_arn            = module.alb.alb_arn
  listener_https_arn = module.alb.listener_https_arn
  listener_test_arn  = module.alb.listener_test_arn
  vpc_id             = var.vpc_id
}

module "svc_moments_api" {
  source             = "../../modules/ecs_service"
  cluster_arn        = aws_ecs_cluster.this.arn
  service_name       = "api-moments"
  container_name     = "moments-api"
  image              = var.img_moments_api
  port               = 8010
  env                = {}
  sg_tasks_id        = aws_security_group.tasks.id
  private_subnets    = var.private_subnets
  alb_arn            = module.alb.alb_arn
  listener_https_arn = module.alb.listener_https_arn
  listener_test_arn  = module.alb.listener_test_arn
  vpc_id             = var.vpc_id
}

module "svc_emotion_api" {
  source             = "../../modules/ecs_service"
  cluster_arn        = aws_ecs_cluster.this.arn
  service_name       = "api-emotion"
  container_name     = "emotion-api"
  image              = var.img_emotion_api
  port               = 8020
  env                = {}
  sg_tasks_id        = aws_security_group.tasks.id
  private_subnets    = var.private_subnets
  alb_arn            = module.alb.alb_arn
  listener_https_arn = module.alb.listener_https_arn
  listener_test_arn  = module.alb.listener_test_arn
  vpc_id             = var.vpc_id
}

module "svc_voice_api" {
  source             = "../../modules/ecs_service"
  cluster_arn        = aws_ecs_cluster.this.arn
  service_name       = "api-voice"
  container_name     = "voice-tone-api"
  image              = var.img_voice_api
  port               = 8030
  env                = {}
  sg_tasks_id        = aws_security_group.tasks.id
  private_subnets    = var.private_subnets
  alb_arn            = module.alb.alb_arn
  listener_https_arn = module.alb.listener_https_arn
  listener_test_arn  = module.alb.listener_test_arn
  vpc_id             = var.vpc_id
}

module "svc_push_worker" {
  source             = "../../modules/ecs_service"
  cluster_arn        = aws_ecs_cluster.this.arn
  service_name       = "push-worker"
  container_name     = "push-worker"
  image              = var.img_push_worker
  port               = 8787
  env                = {}
  sg_tasks_id        = aws_security_group.tasks.id
  private_subnets    = var.private_subnets
  alb_arn            = module.alb.alb_arn
  listener_https_arn = module.alb.listener_https_arn
  listener_test_arn  = module.alb.listener_test_arn
  vpc_id             = var.vpc_id
}

# Autoscaling examples (chat-web)
resource "aws_appautoscaling_target" "chat" {
  max_capacity       = 8
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.this.name}/chat-web"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}
resource "aws_appautoscaling_policy" "chat_cpu" {
  name               = "chat-cpu-tt"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.chat.resource_id
  scalable_dimension = aws_appautoscaling_target.chat.scalable_dimension
  service_namespace  = aws_appautoscaling_target.chat.service_namespace
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification { predefined_metric_type = "ECSServiceAverageCPUUtilization" }
    target_value       = 55
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

output "alb_dns" { value = module.alb.alb_dns_name }
