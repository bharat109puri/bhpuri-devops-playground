# Commerce Platform Stack

A local, Kubernetes-hosted reference stack for demonstrating application delivery and platform operations:

- MySQL StatefulSet and persistent volume for transactional data
- Redis cache used by the catalog endpoint
- NATS event queue for order and catalog events
- Idempotent Python ingest Job that seeds the catalog
- Python catalog, orders, and events APIs
- Node.js frontend, exposed through a Kubernetes Service and optional Ingress

## Deploy locally

```sh
cd /Users/bpuri/Documents/devops/projects/practice/bhpuri-devops-playground
make up
make ingress-install
make commerce-stack-deploy-local
make commerce-stack-access
```

Open [http://localhost:8083](http://localhost:8083). Keep the access command running. In another terminal, use the service endpoints:

```sh
curl --fail http://localhost:8083/healthz
kubectl -n commerce port-forward svc/catalog-api 8084:80
curl --fail http://localhost:8084/products
curl --fail -X POST http://localhost:8084/orders -H 'content-type: application/json' -d '{"sku":"sku-coffee","quantity":2}'
```

The ingress route sends `/` to the frontend and `/api` to `catalog-api`:

```sh
curl --resolve commerce.local:8080:127.0.0.1 http://commerce.local:8080/api/products
```

Add `127.0.0.1 commerce.local` to your hosts file to browse to `http://commerce.local:8080`.

## Inspect components

```sh
kubectl -n commerce get pods,svc,ingress,job
kubectl -n commerce logs job/commerce-platform-ingest
kubectl -n commerce exec statefulset/commerce-platform-mysql -- mysql -ucommerce -pplayground-app-password -e 'SELECT * FROM products' commerce
```

The defaults are intentionally local-lab credentials. Supply an external Secret and immutable images before using this pattern outside a local environment.
