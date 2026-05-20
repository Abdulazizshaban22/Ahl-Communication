# HOWTO — Grafana SLO & Burn-rate

- **Apdex**: نرسل مقياس `Apdex` لكل خدمة إلى CloudWatch (0..1).
- **Burn-rate**: ننشر مقياس `LatencyBudgetBurnRate` (أعلى من 1 يعني حرق الميزانية أسرع من المسموح).
- استخدم لوحة `ahla_slo_burnrate.json` الجاهزة.

مراجع نظرية: Google SRE Workbook (Alerting on SLOs)، Apdex Spec.