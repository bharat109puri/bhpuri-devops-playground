# Demo Frontend

A dependency-free Node.js frontend deployed to the DevOps Playground with a hardened container image, Helm, Kubernetes probes, and an optional Ingress.

## Run and access locally

From the playground repository root, create the Kind cluster, build and load the local image, deploy the Helm release, then forward the Service:

```sh
cd /Users/bpuri/Documents/devops/projects/practice/bhpuri-devops-playground

make up
make frontend-deploy-local
make frontend-access
```

Open [http://localhost:8082](http://localhost:8082). Keep `make frontend-access` running while using the frontend.

Verify the Kubernetes-served endpoints in another terminal:

```sh
curl --fail http://localhost:8082/healthz
curl --fail http://localhost:8082/readyz
```

## Ingress access

Install the Kind ingress controller, then send a request through the mapped host port:

```sh
make ingress-install
curl --fail --resolve frontend.local:8080:127.0.0.1 http://frontend.local:8080/
```

For browser access, add `127.0.0.1 frontend.local` to your local hosts file and browse to `http://frontend.local:8080`.

## Validation

```sh
node --test tests/server.test.js
helm lint helm
```
