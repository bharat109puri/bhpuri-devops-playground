package main

deny[msg] {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  endswith(container.image, ":latest")
  msg := sprintf("%s uses a mutable image tag", [container.name])
}

deny[msg] {
  input.kind == "Deployment"
  pod_security_context := input.spec.template.spec.securityContext
  not pod_security_context.runAsNonRoot
  msg := sprintf("%s must run as non-root", [input.metadata.name])
}

deny[msg] {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  not container.resources.limits
  msg := sprintf("%s needs resource limits", [container.name])
}
