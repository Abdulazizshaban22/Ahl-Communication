otelcol.receiver.otlp "in" {
  grpc { endpoint = "0.0.0.0:4317" }
  http { endpoint = "0.0.0.0:4318" }
}

otelcol.processor.batch "b" {}
otelcol.exporter.otlp "tempo" { client { endpoint = "http://tempo:4317" } }
loki.write "lokiw" { endpoint { url = "http://loki:3100/loki/api/v1/push" } }

prometheus.remote_write "promw" { endpoint { url = "http://prometheus:9090/api/v1/write" } } # placeholder

# Scrape self and services if needed via prometheus.scrape components.
service "pipelines" {
  pipelines {
    traces  = [otelcol.receiver.otlp.in, otelcol.processor.batch.b, otelcol.exporter.otlp.tempo]
  }
}
