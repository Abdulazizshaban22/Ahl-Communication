# CI/CD
1) Create GitHub OIDC to AWS (role with ECR push + Terraform apply).
2) Configure repo secrets: AWS_ROLE_TO_ASSUME, AWS_REGION, AWS_ACCOUNT_ID.
3) Push to main → builds docker images → push to ECR → (optional) terraform plan/apply via workflow_dispatch.
