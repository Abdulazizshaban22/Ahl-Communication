variable "project" {}
variable "repos" { type = list(string) }
locals { prefix = var.project }
resource "aws_ecr_repository" "repos" {
  for_each = toset(var.repos)
  name = "${local.prefix}/${each.value}"
  image_scanning_configuration { scan_on_push = true }
}
output "repo_urls" { value = { for k, r in aws_ecr_repository.repos: k => r.repository_url } }