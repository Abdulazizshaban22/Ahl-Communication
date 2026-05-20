# Vault
resource "aws_backup_vault" "main" {
  name = "${var.project}-backup-vault"
}

# IAM Role for AWS Backup to access resources
resource "aws_iam_role" "backup_role" {
  name = "${var.project}-backup-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "backup.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "backup_role_policy" {
  name = "${var.project}-backup-policy"
  role = aws_iam_role.backup_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      { Effect: "Allow", Action: ["ec2:Describe*","rds:Describe*","dynamodb:Describe*","efs:Describe*"], Resource: "*" },
      { Effect: "Allow", Action: ["ec2:CreateSnapshot","ec2:CreateTags","ec2:DeleteSnapshot"], Resource: "*" },
      { Effect: "Allow", Action: ["rds:CreateDBSnapshot","rds:DeleteDBSnapshot","rds:AddTagsToResource"], Resource: "*" },
      { Effect: "Allow", Action: ["dynamodb:CreateBackup","dynamodb:DeleteBackup","dynamodb:TagResource"], Resource: "*" },
      { Effect: "Allow", Action: ["efs:CreateBackup","efs:DeleteBackup","efs:TagResource"], Resource: "*" },
      { Effect: "Allow", Action: ["backup:StartBackupJob","backup:List*","backup:Describe*"], Resource: "*" }
    ]
  })
}

# Plan (daily + weekly + monthly)
resource "aws_backup_plan" "plan" {
  name = "${var.project}-backup-plan"

  rule {
    rule_name         = "daily"
    target_vault_name = aws_backup_vault.main.name
    schedule          = "cron(0 2 * * ? *)"     # 02:00 UTC daily
    lifecycle {
      delete_after = var.backup_daily_retention # days
    }
  }

  rule {
    rule_name         = "weekly"
    target_vault_name = aws_backup_vault.main.name
    schedule          = "cron(0 3 ? * MON *)"   # 03:00 UTC Mondays
    lifecycle {
      delete_after = var.backup_weekly_retention # weeks (interpreted as days by AWS Backup)
    }
  }

  rule {
    rule_name         = "monthly"
    target_vault_name = aws_backup_vault.main.name
    schedule          = "cron(0 4 1 * ? *)"     # 04:00 UTC 1st of month
    lifecycle {
      delete_after = var.backup_monthly_retention # months (interpreted as days by AWS Backup)
    }
  }
}

# Selection (attach resources)
resource "aws_backup_selection" "selection" {
  iam_role_arn = aws_iam_role.backup_role.arn
  name         = "${var.project}-backup-selection"
  plan_id      = aws_backup_plan.plan.id
  resources    = var.backup_resources_arns
}
