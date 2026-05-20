# AWS Backup
- List resource ARNs you want protected into `backup_resources_arns`.
- The plan creates Daily/Weekly/Monthly rules into the vault `${var.project}-backup-vault`.
- Restore from AWS Backup console or via CLI.
