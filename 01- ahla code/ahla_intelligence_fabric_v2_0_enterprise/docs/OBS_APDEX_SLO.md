# Observability — Apdex & SLO
- Canary samples `/health` every minute and exports `Duration` metric.
- Alarm approximates **Apdex = (Satisfied + 0.5*Tolerating) / Total** using thresholds T and 4T.
- Consider CloudWatch **Application Signals** SLOs for first-class SLOs once services are detected by Signals.
