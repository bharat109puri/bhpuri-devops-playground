"""Offline-friendly RAG service using LangChain documents and deterministic retrieval."""
from collections.abc import Iterable
from fastapi import FastAPI
from langchain_core.documents import Document
from pydantic import BaseModel

app = FastAPI(title="Local RAG demo", version="0.1.0")

KNOWLEDGE_BASE = [
    Document(page_content="Kind creates disposable Kubernetes clusters using Docker nodes.", metadata={"source": "kind"}),
    Document(page_content="Argo CD continuously reconciles declarative Git state into Kubernetes resources.", metadata={"source": "argocd"}),
    Document(page_content="An SBOM, or software bill of materials, records components included in a container image.", metadata={"source": "sbom"}),
]


def retrieve(question: str, documents: Iterable[Document] = KNOWLEDGE_BASE) -> list[Document]:
    """Tiny lexical retriever for a fully offline demo; swap with a vector store in production."""
    terms = set(question.lower().split())
    ranked = sorted(documents, key=lambda doc: len(terms & set(doc.page_content.lower().split())), reverse=True)
    return [document for document in ranked if terms & set(document.page_content.lower().split())][:2]


class Query(BaseModel):
    question: str


@app.get("/healthz")
def healthz() -> dict[str, str]:
    return {"status": "healthy"}


@app.post("/query")
def query(payload: Query) -> dict[str, object]:
    context = retrieve(payload.question)
    answer = " ".join(document.page_content for document in context) or "No matching local context found."
    return {"answer": answer, "sources": [document.metadata["source"] for document in context]}
