# Stage 1: Build dependencies
FROM python:3.11-slim AS builder
WORKDIR /app

COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Stage 2: Final minimal production image
FROM python:3.11-slim
WORKDIR /app

COPY --from=builder /root/.local /root/.local
COPY app.py .

ENV PATH=/root/.local/bin:$PATH
ENV APP_VERSION=v1.0.0

EXPOSE 8000

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
