# Application stacks

The lab intentionally includes small, operationally equivalent services so CI/CD conventions can be compared without business logic noise.

| Stack | Runtime pattern | Image hardening focus |
| --- | --- | --- |
| Python/Flask | Gunicorn process manager | virtual environment, non-root UID |
| Node.js | built-in HTTP server | Alpine runtime, non-root UID |
| Go | static binary | multi-stage build, distroless non-root runtime |

Every service exposes `GET /healthz` on port `8080`. This makes liveness/readiness behaviour and smoke tests consistent across stacks.
