# Demo API incident runbook

## Trigger

`DemoApiHighErrorRate` fires when the five-minute 5xx ratio is above 5% for five minutes.

## Evidence-first response

1. Check the active Argo Rollout and pause/abort the canary if the bad revision is receiving traffic.
2. Inspect the trace in Jaeger using the affected request timestamp and correlate `service.name=demo-api`.
3. Inspect pod events, previous logs, resource saturation, and dependency errors.
4. If the current revision is the cause, run `kubectl argo rollouts abort demo-api -n <environment>` and record the revision/image digest.
5. Open a corrective PR that updates the environment value file with a verified digest; do not re-use a mutable tag.
