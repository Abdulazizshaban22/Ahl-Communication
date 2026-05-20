variable "project" {}
variable "params" { type = map(string) }
resource "aws_ssm_parameter" "params" {
  for_each = var.params
  name = each.key
  type = "String"
  value = each.value
}