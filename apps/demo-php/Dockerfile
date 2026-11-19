# syntax=docker/dockerfile:1.7
FROM php:8.3-cli-alpine
RUN addgroup -S app && adduser -S -G app -u 10001 app
WORKDIR /app
COPY --chown=app:app public ./public
USER 10001:10001
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 CMD php -r 'exit((int)!@file_get_contents("http://127.0.0.1:8080/healthz"));'
CMD ["php", "-S", "0.0.0.0:8080", "-t", "public"]
