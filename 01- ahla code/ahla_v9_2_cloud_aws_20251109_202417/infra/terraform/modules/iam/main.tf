variable "project" {}
data "aws_iam_policy_document" "task_assume" {
  statement { actions = ["sts:AssumeRole"], principals { type = "Service", identifiers = ["ecs-tasks.amazonaws.com"] } }
}
resource "aws_iam_role" "execution" {
  name = "${var.project}-ecs-execution"
  assume_role_policy = data.aws_iam_policy_document.task_assume.json
}
resource "aws_iam_role_policy_attachment" "ecr" {
  role = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
resource "aws_iam_role" "task" {
  name = "${var.project}-ecs-task"
  assume_role_policy = data.aws_iam_policy_document.task_assume.json
}
output "execution_role_arn" { value = aws_iam_role.execution.arn }
output "task_role_arn" { value = aws_iam_role.task.arn }