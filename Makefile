CLUSTER_NAME := bhpuri-lab
KIND_CONTEXT := kind-$(CLUSTER_NAME)

.DEFAULT_GOAL := help
.PHONY: help up down argocd-install argocd-password argocd-ui bootstrap ingress-install frontend-deploy-local frontend-access commerce-stack-deploy-local commerce-stack-access observability-install platform-operators-install platform-config-apply test-gha verify lint render build-images compose-up compose-down

help: ## Show available commands
	@awk 'BEGIN {FS = ":.*##"}; /^[a-zA-Z_-]+:.*##/ {printf "\\033[36m%-18s\\033[0m %s\\n", $$1, $$2}' $(MAKEFILE_LIST)

up: ## Create the local multi-node Kubernetes cluster
	kind create cluster --config cluster/kind-config.yaml
	kubectl cluster-info --context $(KIND_CONTEXT)

argocd-install: ## Install Argo CD with Helm
	helm repo add argo https://argoproj.github.io/argo-helm --force-update
	helm upgrade --install argocd argo/argo-cd --namespace argocd --create-namespace --set server.service.type=ClusterIP --wait --timeout 10m

bootstrap: up argocd-install ## Create cluster, install Argo CD, and apply root application
	kubectl apply -f argocd/projects/playground.yaml
	kubectl apply -f argocd/root-app.yaml

argocd-password: ## Print the initial Argo CD admin password
	@kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 --decode; echo

argocd-ui: ## Forward Argo CD UI to https://localhost:8081
	kubectl -n argocd port-forward svc/argocd-server 8081:443

ingress-install: ## Install ingress-nginx for Kind host ports 8080 and 8443
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.12.0/deploy/static/provider/kind/deploy.yaml
	kubectl -n ingress-nginx rollout status deployment/ingress-nginx-controller --timeout=180s

frontend-deploy-local: ## Build, load, and deploy the Node frontend to Kind
	docker build --tag demo-frontend:local apps/demo-frontend
	kind load docker-image demo-frontend:local --name $(CLUSTER_NAME)
	helm upgrade --install demo-frontend apps/demo-frontend/helm --namespace playground --create-namespace \
		--set image.repository=demo-frontend --set image.tag=local --set image.pullPolicy=Never --set ingress.enabled=true
	kubectl -n playground rollout status deployment/demo-frontend --timeout=180s

frontend-access: ## Forward the frontend to http://localhost:8082
	kubectl -n playground port-forward svc/demo-frontend 8082:80

commerce-stack-deploy-local: ## Build and deploy MySQL, Redis, NATS, APIs, ingest, and frontend
	docker build --tag commerce-api:local apps/commerce-platform/api
	docker build --tag commerce-frontend:local apps/commerce-platform/frontend
	kind load docker-image commerce-api:local commerce-frontend:local --name $(CLUSTER_NAME)
	helm upgrade --install commerce-platform apps/commerce-platform/helm --namespace commerce --create-namespace
	kubectl -n commerce rollout status statefulset/commerce-platform-mysql --timeout=240s
	kubectl -n commerce rollout status deployment/catalog-api --timeout=180s
	kubectl -n commerce rollout status deployment/commerce-platform-frontend --timeout=180s

commerce-stack-access: ## Forward commerce frontend to http://localhost:8083
	kubectl -n commerce port-forward svc/commerce-platform-frontend 8083:80

observability-install: ## Install local Prometheus, Grafana, and Loki
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts --force-update
	helm repo add grafana https://grafana.github.io/helm-charts --force-update
	kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
	kubectl -n monitoring create secret generic grafana-admin --from-literal=admin-user=admin --from-literal=admin-password="$${GRAFANA_ADMIN_PASSWORD:-change-me-before-sharing}" --dry-run=client -o yaml | kubectl apply -f -
	helm upgrade --install monitoring prometheus-community/kube-prometheus-stack --namespace monitoring -f observability/kube-prometheus-stack-values.yaml
	helm upgrade --install loki grafana/loki --namespace monitoring -f observability/loki-values.yaml
	kubectl apply -f observability/demo-api-dashboard.yaml
	kubectl apply -f observability/otel/jaeger.yaml
	kubectl apply -f observability/alerts/demo-api-slo.yaml
	helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts --force-update
	helm upgrade --install otel-collector open-telemetry/opentelemetry-collector --namespace monitoring -f observability/otel/collector-values.yaml

platform-operators-install: ## Install local policy and external-secret operators
	helm repo add external-secrets https://charts.external-secrets.io --force-update
	helm repo add kyverno https://kyverno.github.io/kyverno/ --force-update
	helm upgrade --install external-secrets external-secrets/external-secrets --namespace external-secrets --create-namespace
	helm upgrade --install kyverno kyverno/kyverno --namespace kyverno --create-namespace

platform-config-apply: ## Apply local secrets, policy, backup, and chaos drill manifests
	kubectl apply -f platform/external-secrets/local-store.yaml
	kubectl apply -f platform/external-secrets/rag-api-key.yaml
	kubectl apply -f platform/kyverno/policies.yaml
	@echo "Velero and Chaos Mesh CRDs are intentionally installed separately; see docs/platform-operations.md."

verify: ## Check the demo application rollout
	kubectl -n demo-api rollout status deployment/demo-api --timeout=120s
	kubectl -n demo-api get all

lint: ## Lint all Helm charts and render Kubernetes manifests
	helm lint apps/demo-api/helm
	helm template demo-api apps/demo-api/helm > /dev/null

render: ## Render GitOps manifests locally
	kubectl kustomize gitops/overlays/dev > /dev/null

build-images: ## Build all local application images
	docker build --tag demo-api:local apps/demo-api
	docker build --tag demo-frontend:local apps/demo-frontend
	docker build --tag commerce-api:local apps/commerce-platform/api
	docker build --tag commerce-frontend:local apps/commerce-platform/frontend
	docker build --tag demo-node:local apps/demo-node
	docker build --tag demo-go:local apps/demo-go
	docker build --tag demo-spring:local apps/demo-spring
	docker build --tag demo-php:local apps/demo-php
	docker build --tag ai-rag:local apps/ai-rag
	docker build --tag ai-langgraph:local apps/ai-langgraph
	docker build --tag mcp-tool-server:local apps/mcp-tool-server

compose-up: ## Run all application stacks with Docker Compose
	docker compose up --build

compose-down: ## Stop local Docker Compose workloads
	docker compose down --remove-orphans

test-gha: ## Run GitHub Actions locally with act
	act -P ubuntu-latest=catthehacker/ubuntu:act-latest

down: ## Delete the local Kind cluster
	kind delete cluster --name $(CLUSTER_NAME)
