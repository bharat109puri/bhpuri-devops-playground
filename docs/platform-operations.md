# Platform operations lab

## Secrets

Install External Secrets Operator and create a local source secret without committing its value:

```sh
kubectl -n playground create secret generic local-rag-source --from-literal=api-key=replace-me
kubectl apply -f platform/external-secrets/local-store.yaml
kubectl apply -f platform/external-secrets/rag-api-key.yaml
```

The Kubernetes provider is intentionally a local teaching setup. Use cloud secret-manager identity (for example IRSA/Workload Identity) in non-local environments.

## Policy

Kyverno starts in `Audit` mode so violations are visible before enforcement. Review policy reports, then change `validationFailureAction` to `Enforce` only after the workloads comply.

## Backup and chaos recovery

The Velero schedule and Chaos Mesh experiment are declarative drill inputs. Install/configure a real object-store backup location before applying Velero resources. Capture recovery evidence: backup ID, restore duration, restored rollout health, and SLO impact.
