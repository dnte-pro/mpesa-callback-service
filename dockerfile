# Stage 1: Build dependencies
FROM python:3.11-slim AS builder
WORKDIR /app
RUN pip install --no-cache-dir poetry

COPY pyproject.toml poetry.lock* ./ 
# Or if using pip requirements: COPY requirements.txt .
RUN pip install --user --no-cache-dir fastapi uvicorn pydantic

# Stage 2: Final minimal production image
FROM python:3.11-slim
WORKDIR /app

# Copy installed dependencies from the builder stage
COPY --from=builder /root/.local /root/.local
COPY app.py .

ENV PATH=/root/.local/bin:$PATH
ENV APP_VERSION=v1.0.0

EXPOSE 8000

# Run using Uvicorn production server
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
