# Observability lab

The lab uses the Prometheus community chart for metrics/Grafana and Grafana Loki for logs. Values files are intentionally small and resource-bounded for a laptop cluster.

```sh
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack -n monitoring --create-namespace -f observability/kube-prometheus-stack-values.yaml
helm upgrade --install loki grafana/loki -n monitoring -f observability/loki-values.yaml
kubectl apply -f observability/demo-api-dashboard.yaml
```

The Grafana administrator password in the example is only suitable for an ephemeral local lab. In real environments, supply it through an external secret manager.
