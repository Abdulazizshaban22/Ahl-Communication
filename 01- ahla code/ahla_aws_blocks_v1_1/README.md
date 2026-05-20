# Ahla AWS Blocks v1.1 — (1) S3 Production + (2) Secrets Wiring + (3) TURN TLS Ready

This add-on extends **ahla_aws_golive_v1** with:
1) **Drive → AWS S3 Production** (CORS, IAM, bucket policy, ALB/LB rules, ECS task role)
2) **Secrets Manager / SSM wiring** in ECS tasks (examples for TURN user/pass and SMTP)
3) **TURN over TLS (5349)** behind **NLB**, with coturn bootstrapping of certificates

> Apply from `terraform/` after merging with your previous Go-Live package.
> Files are additive; if a file already exists in your tree, replace or merge accordingly.
