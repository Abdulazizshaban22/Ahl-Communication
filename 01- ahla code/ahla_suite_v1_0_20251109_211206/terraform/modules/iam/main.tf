
data "aws_iam_policy_document" "ecs_tasks_assume" {
  statement { actions = ["sts:AssumeRole"]
    principals { type="Service", identifiers=["ecs-tasks.amazonaws.com"] }
  }
}
resource "aws_iam_role" "task_exec" {
  name = "ahla-ecs-exec"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume.json
}
resource "aws_iam_role_policy_attachment" "exec_attach" {
  role = aws_iam_role.task_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
output "task_exec_role_arn" { value = aws_iam_role.task_exec.arn }
