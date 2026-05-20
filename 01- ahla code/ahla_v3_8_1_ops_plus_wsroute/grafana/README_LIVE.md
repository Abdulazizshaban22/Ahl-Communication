# Grafana Live
- Enable Grafana Live to push real-time data into panels (no polling). See official docs.
- Optionally stream from Telegraf/MQTT or custom producers to Live channels.

Mount provisioning:
  docker run -v $PWD/grafana/provisioning:/etc/grafana/provisioning              -v $PWD/grafana/dashboards:/var/lib/grafana/dashboards grafana/grafana
