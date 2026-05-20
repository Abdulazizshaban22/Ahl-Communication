FROM python:3.11-slim
WORKDIR /app
RUN pip install requests==2.32.3 redis==5.0.8
COPY app ./app
CMD ["python","app/main.py"]
