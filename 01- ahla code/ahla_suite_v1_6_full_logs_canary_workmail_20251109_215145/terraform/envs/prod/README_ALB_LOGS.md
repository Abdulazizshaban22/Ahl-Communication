
# In envs/prod/main.tf ensure you pass logging bucket to ALB:
# module "alb" {
#   source = "../../modules/alb"
#   vpc_id = var.vpc_id
#   public_subnets = var.public_subnets
#   certificate_arn = var.certificate_arn
#   domain_name = var.domain_name
#   route53_zone_id = var.route53_zone_id
#   enable_access_logs = true
#   access_logs_bucket = module.alb_logs.alb_logs_bucket_name
# }
