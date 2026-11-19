# Progressive delivery flow

1. A pull request runs lint, policy, language, and ephemeral-Kind deployment checks.
2. A merge to `main` builds a multi-architecture image, scans it, signs it through GitHub OIDC, produces an SBOM, and creates a GitHub artifact attestation.
3. A promotion pull request updates `apps/demo-api/helm/environments/dev.yaml` with the generated immutable image reference.
4. A reviewer promotes the same reference to staging, where Argo Rollouts uses canary steps and the SLO alert/runbook pair supplies operational evidence.
5. Production promotion is another reviewed values-only change. Abort a bad rollout with `kubectl argo rollouts abort demo-api -n demo-api-prod` and retain the image digest in the incident record.

The checked-in values use `sha-REPLACE_*` placeholders so that an image cannot be mistaken for a real release. Replace them only through a reviewed promotion change.
