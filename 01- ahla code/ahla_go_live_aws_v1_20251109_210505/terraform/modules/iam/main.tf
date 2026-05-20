
data "aws_iam_policy_document" "ecs_tasks_assume" {
  statement { actions = ["sts:AssumeRole"]
    principals { type = "Service" identifiers = ["ecs-tasks.amazonaws.com"] }
  }
}
resource "aws_iam_role" "task_exec" {
  name               = "ahla-ecs-exec"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume.json
}
resource "aws_iam_role_policy_attachment" "exec_attach" {
  role       = aws_iam_role.task_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
# CodeDeploy role for ECS blue/green
data "aws_iam_policy_document" "codedeploy_assume" {
  statement { actions = ["sts:AssumeRole"]
    principals { type = "Service" identifiers = ["codedeploy.amazonaws.com"] }
  }
}
resource "aws_iam_role" "codedeploy" {
  name               = "ahla-codedeploy-ecs"
  assume_role_policy = data.aws_iam_policy_document.codedeploy_assume.json
}
resource "aws_iam_role_policy_attachment" "codedeploy_attach" {
  role       = aws_iam_role.codedeploy.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRoleForECS"
}

output "task_exec_role_arn" { value = aws_iam_role.task_exec.arn }
output "codedeploy_role_arn" { value = aws_iam_role.codedeploy.arn }
