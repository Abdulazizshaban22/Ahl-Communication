
# Mail Web
module "svc_mail_web" {
  source             = "../../modules/ecs_service"
  aws_region         = var.region
  cluster_arn        = aws_ecs_cluster.this.arn
  service_name       = "mail-web"
  container_name     = "mail-web"
  image              = var.img_mail_web
  port               = 3200
  env                = { NEXT_PUBLIC_BASE_PATH="/mail" }
  log_group_name     = "/ecs/ahla/mail-web"
  sg_tasks_id        = aws_security_group.tasks.id
  private_subnets    = var.private_subnets
  listener_https_arn = module.alb.listener_https_arn
  vpc_id             = var.vpc_id
}

# Mail API (bridges IMAP/SMTP)
module "svc_mail_api" {
  source             = "../../modules/ecs_service"
  aws_region         = var.region
  cluster_arn        = aws_ecs_cluster.this.arn
  service_name       = "mail-api"
  container_name     = "mail-api"
  image              = var.img_mail_api
  port               = 8300
  env = {
    IMAP_HOST     = var.mail_imap_host
    IMAP_PORT     = tostring(var.mail_imap_port)
    IMAP_SECURE   = var.mail_imap_secure ? "true" : "false"
    SMTP_HOST     = var.mail_smtp_host
    SMTP_PORT     = tostring(var.mail_smtp_port)
    SMTP_SECURE   = var.mail_smtp_secure ? "true" : "false"
  }
  secrets = [
    { name="MAIL_USER", valueFrom=var.ssm_mail_user },
    { name="MAIL_PASS", valueFrom=var.ssm_mail_pass }
  ]
  log_group_name     = "/ecs/ahla/mail-api"
  sg_tasks_id        = aws_security_group.tasks.id
  private_subnets    = var.private_subnets
  listener_https_arn = module.alb.listener_https_arn
  vpc_id             = var.vpc_id
}
