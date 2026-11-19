CLUSTER_NAME := bhpuri-lab
KIND_CONTEXT := kind-$(CLUSTER_NAME)

.DEFAULT_GOAL := help
.PHONY: help up down argocd-install argocd-password argocd-ui bootstrap observability-install test-gha verify lint render build-images

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
	kubectl apply -f argocd/applications/platform.yaml

argocd-password: ## Print the initial Argo CD admin password
	@kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 --decode; echo

argocd-ui: ## Forward Argo CD UI to https://localhost:8081
	kubectl -n argocd port-forward svc/argocd-server 8081:443

observability-install: ## Install local Prometheus, Grafana, and Loki
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts --force-update
	helm repo add grafana https://grafana.github.io/helm-charts --force-update
	helm upgrade --install monitoring prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace -f observability/kube-prometheus-stack-values.yaml
	helm upgrade --install loki grafana/loki --namespace monitoring -f observability/loki-values.yaml
	kubectl apply -f observability/demo-api-dashboard.yaml

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
	docker build --tag demo-node:local apps/demo-node
	docker build --tag demo-go:local apps/demo-go

test-gha: ## Run GitHub Actions locally with act
	act -P ubuntu-latest=catthehacker/ubuntu:act-latest

down: ## Delete the local Kind cluster
	kind delete cluster --name $(CLUSTER_NAME)
