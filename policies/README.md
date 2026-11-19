# Policy as code

These Conftest/Rego rules are a deliberately small admission-like guardrail for CI. They reject mutable image tags and require a non-root runtime plus resource limits for Deployments.

Run them against the chart locally when Docker is available:

```sh
helm template demo-api apps/demo-api/helm > /tmp/demo-api.yaml
docker run --rm -v "$PWD:/project" -w /project openpolicyagent/conftest:v0.56.0 test /tmp/demo-api.yaml --policy policies
```

Policy-as-code complements—not replaces—cluster admission controls. Promote mature policies into Kyverno or Gatekeeper before enforcing them in a shared platform.
