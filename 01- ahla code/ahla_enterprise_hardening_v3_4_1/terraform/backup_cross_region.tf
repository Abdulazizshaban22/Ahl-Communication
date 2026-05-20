# Secondary region provider alias
provider "aws" {
  alias  = "secondary"
  region = var.secondary_region
}

# Destination vault in secondary region
resource "aws_backup_vault" "secondary_vault" {
  provider = aws.secondary
  name     = "${var.project}-backup-vault-secondary"
}

# In your existing backup_plan rule, add a copy_action to the secondary vault
# Example rule with copy_action:
resource "aws_backup_plan" "plan_with_copy" {
  name = "${var.project}-backup-plan-copy"

  rule {
    rule_name         = "daily-with-copy"
    target_vault_name = aws_backup_vault.main.name
    schedule          = "cron(0 2 * * ? *)"
    lifecycle { delete_after = var.backup_daily_retention }

    copy_action {
      destination_vault_arn = aws_backup_vault.secondary_vault.arn
      lifecycle {
        delete_after = var.backup_daily_retention  # retention for the copy
      }
    }
  }
}
