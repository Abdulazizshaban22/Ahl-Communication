# Autoscaling for DaemonSet
- Kubernetes **HPA does not support DaemonSet**. Use **Cluster Autoscaler** to add/remove nodes.
- Alternatively run CoTURN as **Deployment + HPA** (see sibling folder) for pod-level scaling.
- NLB target type is set to **instance** and `externalTrafficPolicy: Local` to preserve client IP.
