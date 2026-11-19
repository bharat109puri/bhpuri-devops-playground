# DevOps Playground

[![Continuous integration](https://github.com/bharat109puri/bhpuri-devops-playground/actions/workflows/ci.yml/badge.svg)](https://github.com/bharat109puri/bhpuri-devops-playground/actions/workflows/ci.yml)

An opinionated, reproducible local platform lab for demonstrating modern delivery practices without requiring a cloud account. Three small application stacks share the same operational contract, making container, Kubernetes, GitOps, security, and observability techniques easy to compare.

## What it demonstrates

- Local multi-node Kubernetes with Kind and one-command automation through `make`
- Hardened Python, Node.js, and Go container examples
- Java Spring Boot, PHP, local RAG, LangGraph, and MCP server examples
- Helm schema validation, HPA, PDB, NetworkPolicy, probes, resource limits, and non-root security context
- Multi-environment Argo CD ApplicationSet and Argo Rollouts canary delivery
- Kustomize environment overlay and Kubernetes Pod Security admission labels
- Prometheus, Grafana, Loki, Jaeger, OpenTelemetry Collector, alerting rules, and dashboard-as-code
- GitHub Actions for validation, ephemeral-Kind deployment tests, secret/config and image scanning, signing, attestations, SBOMs, multi-architecture publishing, and Dependabot updates
- External Secrets, Kyverno audit policies, Velero backup schedules, and Chaos Mesh drill manifests

## Architecture

```text
                        pull request
Developer ─────────────────────────────────► GitHub Actions
    │                                      ├─ validate Helm / Kubernetes schema
    │                                      ├─ scan IaC and secrets
    │                                      └─ build OCI images + SBOM
    │
    └─ make bootstrap ─► Kind cluster ────► Argo CD ────► Helm / Kustomize
                              │                                  │
                              └─ Prometheus + Grafana + Loki ◄───┘
```

## Quick start

Install and authenticate Docker Desktop (or another Docker-compatible daemon), then install the core clients:

```sh
brew install kind kubectl helm argocd act
```

```sh
git clone git@github.com:bharat109puri/bhpuri-devops-playground.git
cd bhpuri-devops-playground
make bootstrap
make argocd-password
make argocd-ui
```

Argo CD is available at `https://localhost:8081`. The applications sync from this repository’s `main` branch. Before pushing, you can deploy directly:

```sh
helm upgrade --install demo-api apps/demo-api/helm --namespace demo-api --create-namespace
kubectl -n demo-api port-forward svc/demo-api 8080:80
curl http://localhost:8080/healthz
```

Use `make down` to remove the cluster.

## Local workflows

```sh
make lint          # Helm lint + rendering
make render        # render the Kustomize development overlay
make build-images  # build all three application images
make test-gha      # execute compatible workflows locally with act
make observability-install
```

To run every service without Kubernetes, use Docker Compose. The HTTP endpoints are mapped from `8080` through `8087`:

```sh
make compose-up
```

The CI runner has a full Docker environment, whereas some hosted/sandboxed terminals do not allow local port binding. GitHub Actions is the canonical container verification path.

## Applications

Every service listens on port `8080` and exposes `GET /healthz`.

| Service | Stack | Container approach |
| --- | --- | --- |
| `demo-api` | Flask + Gunicorn | multi-stage Python virtual environment, non-root runtime |
| `demo-node` | Node.js HTTP | minimal Alpine, non-root runtime |
| `demo-go` | Go HTTP | static binary in distroless non-root image |
| `demo-spring` | Java Spring Boot | Maven build with Java 21 JRE runtime |
| `demo-php` | PHP | non-root PHP CLI lab server |
| `ai-rag` | FastAPI + LangChain | local deterministic retrieval, no API key required |
| `ai-langgraph` | FastAPI + LangGraph | deployable state-graph workflow |
| `mcp-tool-server` | MCP Python SDK | tools, resource, and prompt over Streamable HTTP |

See [application stack notes](docs/application-stacks.md) for the design differences.
Read [the AI and MCP guide](docs/ai-and-mcp.md) before connecting model credentials or an MCP host.
Use the [polyglot deployment guide](docs/deploy-polyglot.md) to deploy the additional services with the shared chart.

## Repository layout

```text
apps/           application examples and deployment chart
argocd/         Argo CD project and application definitions
cluster/        Kind topology
gitops/         Kustomize platform foundations and environments
observability/  Helm values and Grafana dashboard-as-code
policies/       policy-as-code examples (safe to extend)
.github/        CI, security, publishing, and dependency automation
```

## Delivery and security model

Pull requests validate application syntax, Helm templates, and rendered Kubernetes schemas. Security automation scans configuration and git history for high-severity issues and leaked credentials. Merges to `main` publish multi-architecture images to GHCR, attach an SPDX SBOM artifact, and cache BuildKit layers.

The release lab promotes an immutable image reference through development, staging, and production value files. Staging and production render an Argo Rollout canary. The E2E workflow builds the image, loads it into a disposable Kind cluster, installs the Rollouts controller, deploys the canary, and verifies `/healthz`.

The chart uses non-root execution, dropped Linux capabilities, a read-only root filesystem, runtime-default seccomp, resource bounds, probes, a NetworkPolicy, HPA, and PDB. These are pragmatic baseline controls, not a claim that the lab is production-certified.

Read [SECURITY.md](SECURITY.md) before reporting a problem, and [CONTRIBUTING.md](CONTRIBUTING.md) before proposing a change.

## Next experiments

1. Add NGINX Ingress and cert-manager with a local issuer.
2. Configure a cloud secret manager and workload identity in a cloud overlay.
3. Connect alert notifications to a local receiver and record a complete incident drill.
4. Enable Kyverno enforcement only after reviewing audit policy reports.
5. Configure Velero against an object store, run restore drills, and retain the recovery evidence.
