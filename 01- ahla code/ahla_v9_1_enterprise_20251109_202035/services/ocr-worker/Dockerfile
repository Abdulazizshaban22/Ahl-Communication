FROM python:3.11-slim
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends tesseract-ocr && rm -rf /var/lib/apt/lists/*
RUN pip install pytesseract==0.3.10
COPY app ./app
VOLUME ["/shared"]
CMD ["python","app/main.py"]
