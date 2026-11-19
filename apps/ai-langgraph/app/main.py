"""A deterministic LangGraph workflow that can be replaced with an LLM-backed node."""
from typing import TypedDict
from fastapi import FastAPI
from langgraph.graph import END, START, StateGraph
from pydantic import BaseModel

app = FastAPI(title="LangGraph workflow demo", version="0.1.0")


class AgentState(TypedDict):
    question: str
    context: str
    answer: str


def retrieve(state: AgentState) -> dict[str, str]:
    return {"context": f"Playground runbook context for: {state['question']}"}


def respond(state: AgentState) -> dict[str, str]:
    return {"answer": f"Grounded workflow response — {state['context']}"}


workflow = StateGraph(AgentState)
workflow.add_node("retrieve", retrieve)
workflow.add_node("respond", respond)
workflow.add_edge(START, "retrieve")
workflow.add_edge("retrieve", "respond")
workflow.add_edge("respond", END)
graph = workflow.compile()


class RunRequest(BaseModel):
    question: str


@app.get("/healthz")
def healthz() -> dict[str, str]:
    return {"status": "healthy"}


@app.post("/run")
def run(payload: RunRequest) -> dict[str, str]:
    result = graph.invoke({"question": payload.question, "context": "", "answer": ""})
    return {"answer": result["answer"]}
