# Ahla IaC v4 → v4.1 Patch
Build: 2025-10-20T05:24:52.974438Z

This patch **merges v5 upgrades** into your existing **Ahla IaC v4 (Helm + Terraform EKS)**:
- Switch **ExternalDNS** to **IRSA** (IAM Role for Service Account) with Route53 least‑privilege.
- Replace in‑cluster **PostgreSQL Helm** with **Amazon RDS (Multi‑AZ)** (+ optional **RDS Proxy**).
- Provision a **K8s Secret** `ahla-system/db-url` for your apps to consume.

## How to apply (safe & incremental)
1) Put this patch folder **next to** your original `ahla_iac_v4_helm_eks/terraform`.
2) Copy the files from `terraform/patch/` into your existing `terraform/` directory (or keep them as separate .tf files).
3) Edit `terraform/terraform.tfvars` and set:
   - `domain = "ahla.com"`
   - `hosted_zone_id = "Zxxxxxxxxxxxx"`  (your Route53 hosted zone ID)
   - `db_*` variables as needed (class, storage, password, etc.).
4) Run:
   ```bash
   cd terraform
   terraform init
   terraform apply
   ```
5) Update your app Deployments to read DB URL from:
   ```yaml
   env:
     - name: DATABASE_URL
       valueFrom:
         secretKeyRef:
           name: db-url
           key: url
   ```
6) **Disable the old PostgreSQL Helm release** from v4 after traffic flips to RDS (see `MIGRATION_NOTES.md`).

> This patch does **not** remove any of your existing v4 files. It adds/overrides behavior with new `.tf` files and deprecates the in‑cluster PostgreSQL Helm release.
