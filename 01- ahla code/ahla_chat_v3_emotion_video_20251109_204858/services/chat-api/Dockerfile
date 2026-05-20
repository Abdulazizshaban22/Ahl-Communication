FROM python:3.11-slim
WORKDIR /app
RUN pip install --no-cache-dir fastapi==0.115.5 uvicorn[standard]==0.32.0 redis==5.0.8 python-multipart==0.0.9
COPY app ./app
VOLUME ["/data"]
EXPOSE 8000
CMD ["uvicorn","app.main:app","--host","0.0.0.0","--port","8000"]