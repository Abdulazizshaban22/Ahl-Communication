
# Ahla Suite v3.5 — Intelligence + Cloud (Production Skeleton)

This package delivers the **AI Intelligence Fabric** (Emotion, Talk, AI Orchestrator, Analyze) wired for integration with Ahla Chat/Meet and a **cloud IaC** stack (Terraform) for AWS (ECS, MSK IAM, OpenSearch Ingestion, CloudFront+WAF, Keycloak placeholders).

> **Dev run** uses Docker Compose with Redpanda (Kafka-compatible) and local services. **Prod** uses Terraform modules (fill `prod.tfvars`).

## Quickstart (Dev)

```bash
cp .env.example .env
docker compose -f docker-compose.dev.yml up -d --build
# Open services:
#  - Orchestrator: http://localhost:8000/docs
#  - Emotion: http://localhost:8001/docs
#  - Talk (ASR/TTS): http://localhost:8002/docs
#  - Analyze: http://localhost:8003/docs
```

## Quickstart (Prod — AWS)

1) Fill `infra/terraform/prod.tfvars` with your ARNs/IDs (VPC, subnets, certs).  
2) From `infra/terraform`:
```bash
terraform init
terraform plan -var-file=prod.tfvars
terraform apply -var-file=prod.tfvars
```
This provisions MSK (IAM), OpenSearch (+Ingestion + GeoIP), ECS services for Emotion/Talk/AI/Analyze, ALB behind CloudFront+WAF (BotControl+ATP).

## Services
- **/services/ahla-emotion** — Arabic sentiment & tone classifier (HF CAMeL-BERT), REST `/analyze_text`.
- **/services/ahla-talk** — Speech pipeline: ASR via local **whisper.cpp** (OpenAI-compatible endpoint) + TTS via **Piper**/**Coqui XTTS**. REST `/asr`, `/tts`.
- **/services/ahla-ai** — Orchestrator & skill router; produces/consumes Kafka topics (`ahla.events`, `ahla.suggestions`) with **MSK IAM** in prod.
- **/services/ahla-analyze** — Observability hooks, pushes logs to OpenSearch Ingestion with GeoIP enrichment.

## Integration
- **Chat/Meet** call Orchestrator webhooks (`/suggest/reply`, `/moderate`) and stream audio to **Talk**. Emotion scores are returned inline and pushed to Kafka.
- **PDPL**: breach workflow stubs (`/pdpl/incident`) and structured logs.

---

© Ahla 2025. This skeleton is production-oriented and ready for extension.
