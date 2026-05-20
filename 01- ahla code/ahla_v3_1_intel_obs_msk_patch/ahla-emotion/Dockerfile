FROM python:3.11-slim
WORKDIR /app
COPY api/ /app/
RUN pip install --no-cache-dir fastapi uvicorn[standard] pydantic
EXPOSE 8088
CMD ["python", "main.py"]
