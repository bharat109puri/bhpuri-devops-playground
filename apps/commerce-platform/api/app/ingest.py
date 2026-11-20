import os
import time

import pymysql

from app.main import MYSQL_DATABASE, MYSQL_HOST, MYSQL_PASSWORD, MYSQL_USER, publish


def connection():
    return pymysql.connect(host=MYSQL_HOST, user=MYSQL_USER, password=MYSQL_PASSWORD, database=MYSQL_DATABASE, autocommit=True)


for attempt in range(30):
    try:
        with connection() as db:
            with db.cursor() as cursor:
                cursor.executemany(
                    "INSERT INTO products (sku, name, price_cents) VALUES (%s, %s, %s) ON DUPLICATE KEY UPDATE name=VALUES(name), price_cents=VALUES(price_cents)",
                    [("sku-coffee", "Platform Coffee", 1299), ("sku-shirt", "Kubernetes T-Shirt", 2499), ("sku-stickers", "DevOps Sticker Pack", 699)],
                )
        publish("catalog.seeded", {"products": 3})
        print("initial catalog data ingested")
        break
    except pymysql.MySQLError:
        if attempt == 29:
            raise
        time.sleep(2)
