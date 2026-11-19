# Contributing

Keep each change small, explain its operational impact, and run `make lint` before opening a pull request. Do not commit credentials, kubeconfigs, Terraform state, or generated manifests containing secrets.

Changes to application images must retain a non-root runtime user, an explicit health endpoint, resource requests and limits, and a passing container smoke test.
