resource "aws_grafana_workspace" "this" {
  name                       = var.amg_workspace_name
  account_access_type        = var.amg_account_access_type
  authentication_providers   = var.amg_auth_providers
  permission_type            = var.amg_permission_type
}

output "grafana_workspace_url" { value = aws_grafana_workspace.this.endpoint }
