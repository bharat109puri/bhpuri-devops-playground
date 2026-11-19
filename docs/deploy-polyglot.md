# Deploying the polyglot examples

The shared `charts/web-service` chart enforces a non-root pod, a read-only root filesystem, resource bounds, and health probes. Each workload has an image-specific values file under `deploy/`.

```sh
helm upgrade --install demo-spring charts/web-service -f deploy/demo-spring/values.yaml -n demo-spring --create-namespace
helm upgrade --install demo-php charts/web-service -f deploy/demo-php/values.yaml -n demo-php --create-namespace
helm upgrade --install ai-rag charts/web-service -f deploy/ai-rag/values.yaml -n ai-rag --create-namespace
helm upgrade --install ai-langgraph charts/web-service -f deploy/ai-langgraph/values.yaml -n ai-langgraph --create-namespace
helm upgrade --install mcp-tool-server charts/web-service -f deploy/mcp-tool-server/values.yaml -n mcp-tool-server --create-namespace
```

The examples refer to GHCR image names. First publish the images through the `Publish images` workflow, or override `image.repository` and `image.tag` for locally loaded Kind images.

For the RAG and LangGraph services, port-forward the Service and call `/docs` for OpenAPI documentation. The MCP server uses Streamable HTTP on port `8000`; connect a compatible MCP host or the MCP Inspector to its exposed MCP endpoint after port-forwarding.
