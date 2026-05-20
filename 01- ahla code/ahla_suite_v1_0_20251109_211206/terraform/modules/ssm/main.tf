
variable "params" { type = map(string) }
resource "aws_ssm_parameter" "this" {
  for_each = var.params
  name  = each.key
  type  = "SecureString"
  value = each.value
}
