
FROM python:3.11-alpine
WORKDIR /app
RUN pip install --no-cache-dir fastapi==0.115.5 uvicorn[standard]==0.32.0 python-multipart==0.0.9 prometheus-client==0.21.0
COPY app ./app
EXPOSE 8010
CMD ["uvicorn","app.main:app","--host","0.0.0.0","--port","8010"]
