# Ahla Suite — Go‑Live AWS (ECS/ALB + NLB TURN + ACM + SSM + Autoscaling)

This package gives you a production **skeleton** to deploy Ahla services on **AWS** using **Terraform** + **ECS Fargate** with:
- **ALB (HTTPS, ACM)** for HTTP APIs and signaling.
- **NLB (UDP 3478 / TCP 5349)** for **TURN (coturn)** traffic.
- **SSM/Secrets Manager** to inject secrets to tasks.
- **TargetTracking AutoScaling** on CPU (easy to swap to p95 latency).
- **Route53** wiring (placeholders).

> Notes:
> - TURN requires **UDP 3478** and (optionally) **TLS on 5349**. We place coturn in **ECS Fargate** behind **NLB**.
> - HTTP services (chat/drive/business/mail/emotion/signaling) are behind **ALB** with HTTPS (ACM).
> - Replace placeholder values in `terraform.tfvars.example` and rename it to `terraform.tfvars`.

## Quickstart
```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# edit domain names and ARNs
terraform init
terraform apply
```

## Services covered in the sample
- VPC, ECS cluster, ALB, NLB
- **chat** service (Node WS) behind ALB (HTTP/HTTPS)
- **meet-signaling** behind ALB
- **coturn** behind NLB (UDP 3478 + TCP 5349)
- Patterns and variables to add drive/business/mail/emotion similarly.

See `e2ee/` for:
- **Chat E2EE (Signal Protocol) minimal demo** (TypeScript pseudocode).
- **WebRTC E2EE (Insertable Streams)** example for browser JS.
