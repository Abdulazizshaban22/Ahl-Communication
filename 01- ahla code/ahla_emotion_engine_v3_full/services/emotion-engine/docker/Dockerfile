# Ahla Emotion Engine v3 - CPU image
FROM python:3.11-slim
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
WORKDIR /app
COPY requirements.txt .
RUN apt-get update && apt-get install -y --no-install-recommends build-essential && rm -rf /var/lib/apt/lists/*
RUN pip install --no-cache-dir -r requirements.txt
COPY src ./src
COPY config ./config
COPY otel ./otel
EXPOSE 8088
CMD ["gunicorn","-k","uvicorn.workers.UvicornWorker","-w","4","-b","0.0.0.0:8088","src.main:app"]
