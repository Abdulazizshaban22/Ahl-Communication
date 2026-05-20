FROM python:3.11-slim
WORKDIR /app
RUN pip install --no-cache-dir fastapi==0.115.5 uvicorn[standard]==0.32.0
COPY app ./app
EXPOSE 8020
CMD ["uvicorn","app.main:app","--host","0.0.0.0","--port","8020"]