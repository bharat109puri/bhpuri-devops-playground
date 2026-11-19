# syntax=docker/dockerfile:1.7
FROM python:3.13-slim AS build
WORKDIR /app
COPY requirements.txt .
RUN python -m venv /venv && /venv/bin/pip install --no-cache-dir -r requirements.txt
FROM python:3.13-slim
RUN groupadd --gid 10001 app && useradd --uid 10001 --gid app --no-create-home app
WORKDIR /app
COPY --from=build /venv /venv
COPY --chown=app:app app ./app
USER 10001:10001
ENV PATH=/venv/bin:$PATH PYTHONUNBUFFERED=1
EXPOSE 8080
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]
