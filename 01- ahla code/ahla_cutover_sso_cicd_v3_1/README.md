# Ahla Suite — v3.1 Cutover + SSO + CI/CD (CloudFront, Keycloak, GitHub OIDC)

This add-on completes:
- **CloudFront full cutover** (Route53 alias + ALB header protection)
- **SSO for Next.js (App Router) with Keycloak via NextAuth v5**
- **CI/CD** (GitHub Actions → ECR push + Terraform plan/apply via AWS OIDC)

> Drop these files into your monorepo (Terraform + Web). Merge/replace as needed.
