# Ahla IaC v4.3 — KEDA Autoscaling for CoTURN
Build: 2025-10-20T05:30:02.016526Z

This patch installs **KEDA** and enables **autoscaling CoTURN (Deployment mode)** based on **Prometheus** metrics:

- Installs KEDA (Helm) into `keda` namespace.
- Adds a **ScaledObject** for the `coturn` **Deployment** in namespace `ahla-system`.
- Scales from **min=2** up to **max=20** replicas based on **Prometheus** query results.
- Uses `turn_total_allocations` & traffic rate as scaling signals (with activation threshold to avoid flapping).
- Includes optional **fallback** replica count if Prometheus is unavailable.

> NOTE: **DaemonSet** mode cannot be scaled by HPA/KEDA. Use **Deployment + HPA/KEDA** for pod-level scale, or rely on **Cluster Autoscaler** for node-level scale in DaemonSet mode.

## Quick start
1) Install KEDA (Helm):
   ```bash
   helm repo add kedacore https://kedacore.github.io/charts
   helm repo update
   helm upgrade --install keda kedacore/keda -n keda --create-namespace
   ```

2) Apply ScaledObject(s):
   ```bash
   kubectl apply -f k8s/keda/scaledobject-coturn-prom.yaml
   # (Optional) apply traffic-based scaler as well
   kubectl apply -f k8s/keda/scaledobject-coturn-traffic.yaml
   ```

3) Verify:
   ```bash
   kubectl -n keda get pods
   kubectl -n ahla-system get scaledobject
   kubectl -n ahla-system describe scaledobject coturn-allocations
   ```

4) Grafana:
   - Import/update your CoTURN & SLO dashboards to visualize allocations/traffic and replica count.
