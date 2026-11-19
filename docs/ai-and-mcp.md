# AI and MCP examples

The AI examples are intentionally deterministic and offline-friendly. They demonstrate deployable service boundaries without requiring an API key or GPU.

- `ai-rag` uses LangChain `Document` objects and a tiny lexical retriever. Replace `retrieve` with a tested embedding model/vector store and inject the LLM API key through an external secret manager for real workloads.
- `ai-langgraph` uses a LangGraph `StateGraph` with retrieve and response nodes. Replace the response node with a model invocation only after adding input/output safety controls, tracing, cost limits, and evaluation datasets.
- `mcp-tool-server` provides an MCP server with tools, a resource, and a prompt. It is pinned to the maintained MCP Python SDK v1 line because the lab source uses the v1 `FastMCP` API. Use the MCP Inspector in development: `uv run mcp dev server.py`.

The MCP Python SDK separates the host/client/server roles; an MCP server provides capabilities but does not itself call an LLM. See the [MCP Python SDK](https://py.sdk.modelcontextprotocol.io/get-started/) for compatible hosts and testing patterns.
