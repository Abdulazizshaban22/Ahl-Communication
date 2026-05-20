# Ahla — Enterprise Hardening Pack v3.4.1
This add-on enables **(1) WebAuthn/Passkeys (Keycloak)**, **(2) S3 Object Lock (Compliance/Governance)**, **(3) AWS Backup Cross‑Region Copy**, and **(4) CloudWatch Synthetics Canaries (TTFB & WS check)**. Apply on top of v3.0–v3.4.

> NOTE: **S3 Object Lock must be enabled at bucket creation.** You cannot enable it later on an existing bucket. Create a new bucket with Object Lock and migrate if needed.

## Quick steps
1) Build & deploy Keycloak with WebAuthn policy.
2) Create the S3 bucket with Object Lock (if you need compliance retention).
3) Apply Terraform for cross‑Region backup copy and canaries.
4) Import the TTFB dashboard into Grafana (optional).
