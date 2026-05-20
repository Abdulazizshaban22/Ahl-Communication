FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY src.py .
EXPOSE 7002
ENV OTEL_EXPORTER_OTLP_ENDPOINT=http://alloy:4317
CMD ["opentelemetry-instrument","uvicorn","src:app","--host","0.0.0.0","--port","7002"]
