# Ahla — Enterprise Hardening Pack v3.4 (MFA + Rotation + Anomaly + Backups)

This pack adds **(A) MFA (Keycloak TOTP)**, **(B) Secrets rotation (AWS Secrets Manager + Lambda)**, **(C) CloudWatch Anomaly Detection alarms**, and **(D) Backups (AWS Backup + S3 lifecycle)**.

> Drop `terraform/` into your stack (v3.0–v3.3). Build the Keycloak image with the MFA patch, then `terraform init && terraform apply`.

## Quick steps
1) **MFA (Keycloak TOTP)**  
   - Build/push the updated Keycloak image in `keycloak-mfa/` then update `var.image_keycloak` in Terraform.
2) **Rotation + Anomaly + Backups + S3 Lifecycle**  
   ```bash
   cd terraform
   cp hardening.tfvars.example terraform.tfvars  # merge into your existing .tfvars if needed
   terraform init
   terraform apply
   ```

See `RUNBOOKS/` for operational procedures.
