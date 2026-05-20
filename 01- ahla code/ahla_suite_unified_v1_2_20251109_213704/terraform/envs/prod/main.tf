
# NOTE: This is a compact unified example.
module "alb" { source = "../../modules/alb"
  vpc_id = var.vpc_id
  public_subnets = var.public_subnets
  certificate_arn = var.certificate_arn
  domain_name = var.domain_name
  route53_zone_id = var.route53_zone_id
}

resource "aws_ecs_cluster" "this" { name = "ahla-cluster" }

resource "aws_security_group" "tasks" {
  name   = "ahla-tasks-sg"
  vpc_id = var.vpc_id
  ingress { from_port=0, to_port=65535, protocol="tcp", security_groups=[module.alb.sg_alb_id] }
  egress  { from_port=0, to_port=0, protocol="-1", cidr_blocks = ["0.0.0.0/0"] }
}

module "redis" {
  source          = "../../modules/elasticache"
  vpc_id          = var.vpc_id
  private_subnets = var.private_subnets
  allowed_sg_id   = aws_security_group.tasks.id
}

# --- Web Apps
module "svc_chat_web" { source = "../../modules/ecs_service" aws_region=var.region
  cluster_arn=aws_ecs_cluster.this.arn, service_name="chat-web", container_name="chat-web", image=var.img_chat_web, port=3000,
  env={ NEXT_PUBLIC_BASE_PATH="/chat" }, secrets=[{name="VAPID_PUBLIC_KEY",valueFrom=var.ssm_vapid_pub},{name="VAPID_PRIVATE_KEY",valueFrom=var.ssm_vapid_priv}],
  log_group_name="/ecs/ahla/chat-web", sg_tasks_id=aws_security_group.tasks.id, private_subnets=var.private_subnets, listener_https_arn=module.alb.listener_https_arn, vpc_id=var.vpc_id }

module "svc_meet_web" { source = "../../modules/ecs_service" aws_region=var.region
  cluster_arn=aws_ecs_cluster.this.arn, service_name="meet-web", container_name="meet-web", image=var.img_meet_web, port=3100,
  env={ NEXT_PUBLIC_BASE_PATH="/meet" }, log_group_name="/ecs/ahla/meet-web", sg_tasks_id=aws_security_group.tasks.id, private_subnets=var.private_subnets, listener_https_arn=module.alb.listener_https_arn, vpc_id=var.vpc_id }

module "svc_drive_web" { source = "../../modules/ecs_service" aws_region=var.region
  cluster_arn=aws_ecs_cluster.this.arn, service_name="drive-web", container_name="drive-web", image=var.img_drive_web, port=3300,
  env={ NEXT_PUBLIC_BASE_PATH="/drive" }, log_group_name="/ecs/ahla/drive-web", sg_tasks_id=aws_security_group.tasks.id, private_subnets=var.private_subnets, listener_https_arn=module.alb.listener_https_arn, vpc_id=var.vpc_id }

module "svc_business_web" { source = "../../modules/ecs_service" aws_region=var.region
  cluster_arn=aws_ecs_cluster.this.arn, service_name="business-web", container_name="business-web", image=var.img_business_web, port=3400,
  env={ NEXT_PUBLIC_BASE_PATH="/business" }, log_group_name="/ecs/ahla/business-web", sg_tasks_id=aws_security_group.tasks.id, private_subnets=var.private_subnets, listener_https_arn=module.alb.listener_https_arn, vpc_id=var.vpc_id }

module "svc_mail_web" { source = "../../modules/ecs_service" aws_region=var.region
  cluster_arn=aws_ecs_cluster.this.arn, service_name="mail-web", container_name="mail-web", image=var.img_mail_web, port=3200,
  env={ NEXT_PUBLIC_BASE_PATH="/mail" }, log_group_name="/ecs/ahla/mail-web", sg_tasks_id=aws_security_group.tasks.id, private_subnets=var.private_subnets, listener_https_arn=module.alb.listener_https_arn, vpc_id=var.vpc_id }

# --- APIs
module "svc_chat_api" { source = "../../modules/ecs_service" aws_region=var.region
  cluster_arn=aws_ecs_cluster.this.arn, service_name="chat-api", container_name="chat-api", image=var.img_chat_api, port=8000,
  env={ REDIS_URL="redis://${module.redis.redis_endpoint}:6379/0", ATTACH_STORE="/data" },
  log_group_name="/ecs/ahla/chat-api", sg_tasks_id=aws_security_group.tasks.id, private_subnets=var.private_subnets, listener_https_arn=module.alb.listener_https_arn, vpc_id=var.vpc_id }

module "svc_meet_api" { source = "../../modules/ecs_service" aws_region=var.region
  cluster_arn=aws_ecs_cluster.this.arn, service_name="meet-api", container_name="meet-api", image=var.img_meet_api, port=8100,
  env={ STUN_URL="stun:stun.l.google.com:19302" }, log_group_name="/ecs/ahla/meet-api", sg_tasks_id=aws_security_group.tasks.id, private_subnets=var.private_subnets, listener_https_arn=module.alb.listener_https_arn, vpc_id=var.vpc_id }

module "svc_drive_api" { source = "../../modules/ecs_service" aws_region=var.region
  cluster_arn=aws_ecs_cluster.this.arn, service_name="drive-api", container_name="drive-api", image=var.img_drive_api, port=8200,
  env={ STORE="/data" }, log_group_name="/ecs/ahla/drive-api", sg_tasks_id=aws_security_group.tasks.id, private_subnets=var.private_subnets, listener_https_arn=module.alb.listener_https_arn, vpc_id=var.vpc_id }

module "svc_business_api" { source = "../../modules/ecs_service" aws_region=var.region
  cluster_arn=aws_ecs_cluster.this.arn, service_name="business-api", container_name="business-api", image=var.img_business_api, port=8250,
  env={}, log_group_name="/ecs/ahla/business-api", sg_tasks_id=aws_security_group.tasks.id, private_subnets=var.private_subnets, listener_https_arn=module.alb.listener_https_arn, vpc_id=var.vpc_id }

module "svc_mail_api" { source = "../../modules/ecs_service" aws_region=var.region
  cluster_arn=aws_ecs_cluster.this.arn, service_name="mail-api", container_name="mail-api", image=var.img_mail_api, port=8300,
  env={ IMAP_HOST=var.mail_imap_host, IMAP_PORT=tostring(var.mail_imap_port), IMAP_SECURE=var.mail_imap_secure ? "true":"false",
        SMTP_HOST=var.mail_smtp_host, SMTP_PORT=tostring(var.mail_smtp_port), SMTP_SECURE=var.mail_smtp_secure ? "true":"false" },
  secrets=[ {name="MAIL_USER", valueFrom=var.ssm_mail_user}, {name="MAIL_PASS", valueFrom=var.ssm_mail_pass} ],
  log_group_name="/ecs/ahla/mail-api", sg_tasks_id=aws_security_group.tasks.id, private_subnets=var.private_subnets, listener_https_arn=module.alb.listener_https_arn, vpc_id=var.vpc_id }

module "svc_emotion_engine" { source = "../../modules/ecs_service" aws_region=var.region
  cluster_arn=aws_ecs_cluster.this.arn, service_name="emotion-engine", container_name="emotion-engine", image=var.img_emotion_engine, port=8400,
  env={}, log_group_name="/ecs/ahla/emotion-engine", sg_tasks_id=aws_security_group.tasks.id, private_subnets=var.private_subnets, listener_https_arn=module.alb.listener_https_arn, vpc_id=var.vpc_id }

module "svc_push_worker" { source = "../../modules/ecs_service" aws_region=var.region
  cluster_arn=aws_ecs_cluster.this.arn, service_name="push-worker", container_name="push-worker", image=var.img_push_worker, port=8787,
  env={ REDIS_URL="redis://${module.redis.redis_endpoint}:6379/0" }, log_group_name="/ecs/ahla/push-worker", sg_tasks_id=aws_security_group.tasks.id, private_subnets=var.private_subnets, listener_https_arn=module.alb.listener_https_arn, vpc_id=var.vpc_id }

module "alerts" {
  source = "../../modules/alarms"
  cluster_name  = aws_ecs_cluster.this.name
  service_names = [ module.svc_chat_web.svc_name, module.svc_meet_web.svc_name, module.svc_drive_web.svc_name, module.svc_business_web.svc_name, module.svc_mail_web.svc_name,
                    module.svc_chat_api.svc_name, module.svc_meet_api.svc_name, module.svc_drive_api.svc_name, module.svc_business_api.svc_name, module.svc_mail_api.svc_name, module.svc_emotion_engine.svc_name, module.svc_push_worker.svc_name ]
  alb_arn_suffix = module.alb.alb_arn_suffix
  sns_email      = var.alerts_email
}

output "alb_dns" { value = module.alb.alb_dns_name }
