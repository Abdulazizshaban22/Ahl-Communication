# Anomaly Alarms
- Set `alb_load_balancer_dimension` to your ALB dimension string (e.g. app/alb-name/uuid).
- Alarms create anomaly bands around p95 TargetResponseTime and 5xx counts (3 periods).
- Adjust `anomaly_band_width` for sensitivity.
