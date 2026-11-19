# DevOps Playground

A reproducible local Kubernetes lab demonstrating Kind, Helm, Argo CD, Docker, and GitHub Actions.

## Architecture

```text
Developer → Makefile → Kind (1 control plane, 2 workers)
                         ├─ Argo CD → Helm chart → demo-api
                         └─ kubectl / act → local verification
```

## Quick start

Prerequisites: Docker, `kind`, `kubectl`, `helm`, `argocd`, and optionally `act`.

```sh
make bootstrap
make argocd-password
make argocd-ui
```

The root Argo CD application is deliberately local-path based so the lab works offline after the required container images have been pulled. Visit the demo app through port-forwarding:

```sh
kubectl -n demo-api port-forward svc/demo-api 8080:80
curl http://localhost:8080/healthz
```

Use `make help` for the full command list, and `make down` to remove the lab.
