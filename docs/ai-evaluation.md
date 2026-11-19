# Local RAG evaluation

The offline RAG example has a versioned retrieval evaluation set under `apps/ai-rag/evals`. CI asserts that each question retrieves the required source. This is intentionally a minimum guardrail.

For a real model-backed deployment, add representative production questions, grounded-answer grading, refusal/safety cases, latency and token-cost budgets, and an approval gate before changing prompts, models, or embedding indexes.
