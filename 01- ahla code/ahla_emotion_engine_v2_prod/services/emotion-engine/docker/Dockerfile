# Ahla Emotion Engine v2 - CPU image
FROM python:3.11-slim
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY src ./src
COPY config ./config
COPY otel ./otel
EXPOSE 8088
# Gunicorn with Uvicorn workers
CMD ["gunicorn","-k","uvicorn.workers.UvicornWorker","-w","4","-b","0.0.0.0:8088","src.main:app"]
