FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY producer.py consumer.py demo_topics.py .
CMD ["python","demo_topics.py"]
