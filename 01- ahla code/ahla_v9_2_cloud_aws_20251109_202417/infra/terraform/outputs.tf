output "alb_dns" { value = module.alb.alb_dns }
output "cluster_name" { value = module.ecs.cluster_name }
output "ecr_repos" { value = module.ecr.repo_urls }