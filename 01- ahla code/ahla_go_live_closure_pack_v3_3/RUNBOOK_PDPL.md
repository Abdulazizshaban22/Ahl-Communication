# PDPL — Incident & Compliance Runbook

## 1) Trigger
- Event types: `incident`, `breach`, `processing`, `access` (from services)
- Services post JSON to `audit-api /audit` with `entity`, `data_category`, `scope`, `impact`, `ts`

## 2) Routing
- Firehose → OpenSearch index `audit-events`
- Firehose S3 backup (immutable, GZIP)

## 3) SLA
- Notify SDAIA within **72 hours** of becoming aware of the incident.
- Notify data subjects if high risk to rights/freedoms exists.
- Keep incident report + corrective actions on record.

## 4) Owner
- DPO / Compliance Officer
- On-call SRE (for technical containment)

## 5) Artefacts
- Timeline, systems impacted, data categories, scope, encryption status, mitigations
- Attach OpenSearch query exports + S3 object paths to the case record

## 6) Contacts
- SDAIA breach portal + internal legal/security distribution

## 7) Close
- Post‑mortem, action items, policy updates
