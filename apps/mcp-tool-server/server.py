"""MCP v1 demo: exposes tools, a resource, and a prompt over streamable HTTP."""
from mcp.server.fastmcp import FastMCP

mcp = FastMCP("devops-playground-tools", json_response=True)


@mcp.tool()
def kubernetes_resource_hint(kind: str) -> str:
    """Return a concise operational hint for a Kubernetes resource kind."""
    hints = {
        "deployment": "Check rollout status, replicas, image digest, probes, and resource limits.",
        "pod": "Inspect events first, then logs from the current and previous container.",
        "service": "Verify selectors match pod labels and endpoints are populated.",
    }
    return hints.get(kind.lower(), "Use kubectl explain and validate the manifest against the cluster API.")


@mcp.resource("playground://runbook")
def runbook() -> str:
    """Provide the local-platform incident runbook."""
    return "Check GitOps sync, deployment rollout, pod events, application health, then observability signals."


@mcp.prompt()
def incident_triage(symptom: str) -> str:
    """Create a safe, evidence-first incident investigation prompt."""
    return f"Investigate this Kubernetes symptom without applying destructive changes: {symptom}"


if __name__ == "__main__":
    mcp.run(transport="streamable-http")
