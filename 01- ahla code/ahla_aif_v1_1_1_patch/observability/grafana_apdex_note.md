# Grafana Apdex
Use a Stat/TimeSeries panel with expression:
Apdex = (satisfied + 0.5 * tolerating) / total
Feed with Synthetics Canary 'Duration' metric binned at thresholds T and 4T using transformations or recording rules.
