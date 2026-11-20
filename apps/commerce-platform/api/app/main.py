import json
import os
import socket
from datetime import datetime, timezone

import pymysql
import redis
from flask import Flask, jsonify, request

app = Flask(__name__)
SERVICE_NAME = os.getenv("SERVICE_NAME", "catalog-api")
MYSQL_HOST = os.getenv("MYSQL_HOST", "commerce-platform-mysql")
MYSQL_DATABASE = os.getenv("MYSQL_DATABASE", "commerce")
MYSQL_USER = os.getenv("MYSQL_USER", "commerce")
MYSQL_PASSWORD = os.environ["MYSQL_PASSWORD"]
REDIS_HOST = os.getenv("REDIS_HOST", "commerce-platform-redis")
NATS_HOST = os.getenv("NATS_HOST", "commerce-platform-nats")


def database():
    return pymysql.connect(
        host=MYSQL_HOST,
        user=MYSQL_USER,
        password=MYSQL_PASSWORD,
        database=MYSQL_DATABASE,
        cursorclass=pymysql.cursors.DictCursor,
        autocommit=True,
    )


def cache():
    return redis.Redis(host=REDIS_HOST, port=6379, decode_responses=True, socket_connect_timeout=1)


def publish(subject, event):
    """Publish a JSON event using NATS' text protocol without a client dependency."""
    payload = json.dumps(event).encode()
    try:
        with socket.create_connection((NATS_HOST, 4222), timeout=1) as connection:
            connection.sendall(b"CONNECT {\"verbose\":false}\r\n")
            connection.sendall(f"PUB {subject} {len(payload)}\r\n".encode() + payload + b"\r\n")
    except OSError:
        app.logger.warning("event broker unavailable; event was not published")


@app.get("/healthz")
def healthz():
    return jsonify(status="healthy", service=SERVICE_NAME)


@app.get("/readyz")
def readyz():
    try:
        with database() as connection:
            with connection.cursor() as cursor:
                cursor.execute("SELECT 1")
        return jsonify(status="ready", service=SERVICE_NAME)
    except pymysql.MySQLError:
        return jsonify(status="not_ready", service=SERVICE_NAME), 503


@app.get("/products")
@app.get("/api/products")
def products():
    client = cache()
    cached = client.get("catalog:products")
    if cached:
        return jsonify(source="redis", products=json.loads(cached))
    with database() as connection:
        with connection.cursor() as cursor:
            cursor.execute("SELECT id, sku, name, price_cents FROM products ORDER BY id")
            rows = cursor.fetchall()
    client.setex("catalog:products", 60, json.dumps(rows))
    return jsonify(source="mysql", products=rows)


@app.post("/orders")
@app.post("/api/orders")
def create_order():
    payload = request.get_json(silent=True) or {}
    sku = payload.get("sku")
    quantity = payload.get("quantity", 1)
    if not isinstance(sku, str) or not sku or not isinstance(quantity, int) or quantity < 1:
        return jsonify(error="sku and a positive integer quantity are required"), 400
    with database() as connection:
        with connection.cursor() as cursor:
            cursor.execute("INSERT INTO orders (sku, quantity) VALUES (%s, %s)", (sku, quantity))
            order_id = cursor.lastrowid
    event = {"id": order_id, "sku": sku, "quantity": quantity, "created_at": datetime.now(timezone.utc).isoformat()}
    publish("orders.created", event)
    return jsonify(order=event), 201


@app.get("/events")
@app.get("/api/events")
def events():
    return jsonify(service=SERVICE_NAME, broker=NATS_HOST, subjects=["orders.created", "catalog.seeded"])


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
